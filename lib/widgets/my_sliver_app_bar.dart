import 'package:flutter/material.dart';

/// 模仿 Microsoft To Do 的应用栏
class MySliverAppBar extends StatefulWidget {
  final String title;
  final List<Widget> actions;

  const MySliverAppBar({
    Key key,
    @required this.title,
    this.actions,
  }) : super(key: key);

  @override
  _MySliverAppBarState createState() => _MySliverAppBarState();
}

class _MySliverAppBarState extends State<MySliverAppBar> {
  final EdgeInsetsTween titlePaddingTween = EdgeInsetsTween(
      begin: EdgeInsets.only(left: 16.0, bottom: 16),
      end: EdgeInsets.only(left: 72.0, bottom: 16));

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: widget.actions,
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final FlexibleSpaceBarSettings settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

          final double deltaExtent = settings.maxExtent - settings.minExtent;

          // 0.0 为展开
          // 1.0 为收起来
          final double t = (1.0 -
                  (settings.currentExtent - settings.minExtent) / deltaExtent)
              .clamp(0.0, 1.0);

          final padding = titlePaddingTween.transform(t);

          return FlexibleSpaceBar(
            title: Text(widget.title),
            titlePadding: padding,
          );
        },
      ),
    );
  }
}
