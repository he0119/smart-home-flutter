import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/bottom_loader.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 无限长列表
///
/// 随着用户的滚动载入新数据
class SliverInfiniteList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 行与行之间的分隔线，只在两行之间插入，最后一行后面不会多一条
  final Widget Function(BuildContext context, T item)? separatorBuilder;
  final bool hasReachedMax;
  final VoidCallback? onFetch;
  final int invisibleItemsThreshold;

  const SliverInfiniteList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
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
    final separator = widget.separatorBuilder;
    // 有分隔线时子项数量是 2n-1，奇偶交错
    final contentCount = separator == null
        ? widget.items.length
        : max(0, widget.items.length * 2 - 1);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        _onBuildChildItem(index);
        if (index >= contentCount) {
          return const BottomLoader();
        }
        if (separator != null && index.isOdd) {
          return separator(context, widget.items[index ~/ 2]);
        }
        return widget.itemBuilder(
          context,
          widget.items[separator == null ? index : index ~/ 2],
        );
      }, childCount: !widget.hasReachedMax ? contentCount + 1 : contentCount),
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

    final newPageRequestTriggerIndex = max(
      0,
      _itemCount - widget.invisibleItemsThreshold,
    );
    final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

    if (isBuildingTriggerIndexItem) {
      widget.onFetch!();
      _hasRequestedNextPage = true;
    }
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
/// hasReachedMax 为 false，底部那条转圈就是「还有下一页」的样子。
@AppPreview(
  name: 'SliverInfiniteList',
  group: previewGroupWidgets,
  size: Size(400, 480),
)
Widget sliverInfiniteListPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: CustomScrollView(
    slivers: <Widget>[
      SliverInfiniteList<String>(
        items: const <String>['电动螺丝刀', '备用电池', '雨伞'],
        itemBuilder: (BuildContext context, String item) =>
            ContentRow(icon: Icons.inbox_outlined, title: Text(item)),
        hasReachedMax: false,
        onFetch: () {},
      ),
    ],
  ),
);
