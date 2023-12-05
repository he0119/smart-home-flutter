import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smarthome/widgets/bottom_loader.dart';

/// 无限长列表
///
/// 随着用户的滚动载入新数据
///
/// 使用的 [ListView.separated], 分隔为 [Divider]
class InfiniteList<T> extends StatefulWidget {
  final List<T> items;
  final List<Widget>? top;
  final List<Widget>? botton;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool hasReachedMax;
  final VoidCallback? onFetch;
  final double threshold;

  const InfiniteList({
    super.key,
    required this.items,
    this.top,
    this.botton,
    required this.itemBuilder,
    this.hasReachedMax = true,
    this.onFetch,
    this.threshold = 200,
  });

  @override
  State<InfiniteList<T>> createState() => _InfiniteListState<T>();
}

class _InfiniteListState<T> extends State<InfiniteList<T>> {
  final _scrollController = ScrollController();

  int current = 0;
  bool get canFetch {
    if (current != widget.items.length) {
      current = widget.items.length;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topCount = widget.top?.length ?? 0;
    final bottonCount = widget.botton?.length ?? 0;
    return Scrollbar(
      controller: _scrollController,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: !widget.hasReachedMax
            ? widget.items.length + 1 + topCount + bottonCount
            : widget.items.length + topCount + bottonCount,
        itemBuilder: (context, index) {
          if (index < topCount) {
            return widget.top![index];
          }
          if (index >= topCount && index < widget.items.length + topCount) {
            return widget.itemBuilder(context, widget.items[index - topCount]);
          }
          if (index >= widget.items.length + topCount &&
              index < widget.items.length + topCount + bottonCount) {
            return widget.botton![index - widget.items.length - topCount];
          }
          return const BottomLoader();
        },
        separatorBuilder: (contexit, index) => const Divider(),
        controller: _scrollController,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= widget.threshold &&
        !widget.hasReachedMax) {
      if (widget.onFetch != null && canFetch) widget.onFetch!();
    }
  }
}

/// 无限长列表
///
/// 随着用户的滚动载入新数据
class SliverInfiniteList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool hasReachedMax;
  final VoidCallback? onFetch;
  final int invisibleItemsThreshold;

  const SliverInfiniteList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.hasReachedMax = true,
    this.onFetch,
    this.invisibleItemsThreshold = 3,
  });

  @override
  State<SliverInfiniteList<T>> createState() => _SliverInfiniteListState<T>();
}

class _SliverInfiniteListState<T> extends State<SliverInfiniteList<T>> {
  bool _hasRequestedNextPage = false;
  int get _itemCount {
    return widget.items.length;
  }

  int _currentItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          _onBuildChildItem(index);
          if (index < widget.items.length) {
            return widget.itemBuilder(context, widget.items[index]);
          }
          return const BottomLoader();
        },
        childCount: !widget.hasReachedMax
            ? widget.items.length + 1
            : widget.items.length,
      ),
    );
  }

  /// 判断是否需要加载新数据
  void _onBuildChildItem(int index) {
    if (widget.onFetch == null) return;

    if (widget.hasReachedMax) return;

    // 如果数据更新了，重置状态
    if (_currentItemCount != _itemCount) {
      _currentItemCount = _itemCount;
      _hasRequestedNextPage = false;
    }

    if (_hasRequestedNextPage) return;

    final newPageRequestTriggerIndex =
        max(0, _itemCount - widget.invisibleItemsThreshold);
    final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

    if (isBuildingTriggerIndexItem) {
      widget.onFetch!();
      _hasRequestedNextPage = true;
    }
  }
}
