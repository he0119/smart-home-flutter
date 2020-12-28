import 'package:flutter/material.dart';

import 'package:smart_home/widgets/bottom_loader.dart';

/// 无限长列表
///
/// 随着用户的滚动载入新数据
///
/// 使用的 [ListView.separated], 分隔为 [Divider]
class InfiniteList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool hasReachedMax;
  final VoidCallback onFetch;
  final double threshold;

  const InfiniteList({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    this.onFetch,
    this.hasReachedMax = true,
    this.threshold = 200,
  })  : assert(hasReachedMax != null),
        super(key: key);

  @override
  _InfiniteListState createState() => _InfiniteListState<T>();
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
    return Scrollbar(
      controller: _scrollController,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: !widget.hasReachedMax
            ? widget.items.length + 1
            : widget.items.length,
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return BottomLoader();
          }
          return widget.itemBuilder(context, widget.items[index]);
        },
        separatorBuilder: (contexit, index) => Divider(),
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
      if (widget.onFetch != null && canFetch) widget.onFetch();
    }
  }
}

class SliverInfiniteList<T> extends StatefulWidget {
  final List<Widget> slivers;
  final bool hasReachedMax;
  final VoidCallback onFetch;
  final double threshold;
  final int itemCount;

  const SliverInfiniteList({
    Key key,
    @required this.slivers,
    this.hasReachedMax = true,
    this.onFetch,
    this.threshold = 200,
    @required this.itemCount,
  })  : assert(hasReachedMax != null),
        super(key: key);

  @override
  _SliverInfiniteListState createState() => _SliverInfiniteListState<T>();
}

class _SliverInfiniteListState<T> extends State<SliverInfiniteList<T>> {
  final _scrollController = ScrollController();

  int current = 0;
  bool get canFetch {
    if (current != widget.itemCount) {
      current = widget.itemCount;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ...widget.slivers,
          if (!widget.hasReachedMax)
            SliverToBoxAdapter(
              child: BottomLoader(),
            ),
        ],
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
      if (widget.onFetch != null && canFetch) widget.onFetch();
    }
  }
}
