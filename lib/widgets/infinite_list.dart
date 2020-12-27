import 'package:flutter/material.dart';
import 'package:smart_home/widgets/bottom_loader.dart';

/// 无限长列表
/// 随着用户的滚动载入新数据
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
  _InfiniteListState createState() => _InfiniteListState();
}

class _InfiniteListState extends State<InfiniteList> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
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
      if (widget.onFetch != null) widget.onFetch();
    }
  }
}
