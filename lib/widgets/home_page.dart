import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/conditional_parent_widget.dart';
import 'package:smarthome/widgets/drawer.dart';
import 'package:smarthome/widgets/tab_selector.dart';

class MyHomePage extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final bool Function()? canPop;
  final void Function(bool, Object?)? onPopInvokedWithResult;

  const MyHomePage({
    super.key,
    required this.title,
    this.actions,
    this.slivers,
    this.floatingActionButton,
    this.onRefresh,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeTab = _getCurrentTab(location);
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.wide;

    void onTabSelected(AppTab tab) {
      switch (tab) {
        case AppTab.storage:
          context.go('/storage');
          break;
        case AppTab.blog:
          context.go('/blog');
          break;
        case AppTab.board:
          context.go('/board');
          break;
      }
    }

    return MySliverScaffold(
      title: Text(title),
      actions: actions,
      slivers: slivers,
      drawer: const MyDrawer(),
      floatingActionButton: floatingActionButton,
      onRefresh: onRefresh,
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      navigationRail: wide
          ? NavigationRail(
              selectedIndex: AppTab.values.indexOf(activeTab),
              onDestinationSelected: (int index) =>
                  onTabSelected(AppTab.values[index]),
              labelType: NavigationRailLabelType.all,
              destinations: AppTab.values
                  .map(
                    (AppTab tab) => NavigationRailDestination(
                      icon: tab.icon,
                      label: Text(tab.name),
                    ),
                  )
                  .toList(),
            )
          : null,
      bottomNavigationBar: wide
          ? null
          : TabSelector(activeTab: activeTab, onTabSelected: onTabSelected),
    );
  }

  AppTab _getCurrentTab(String location) {
    if (location.startsWith('/storage')) return AppTab.storage;
    if (location.startsWith('/blog')) return AppTab.blog;
    if (location.startsWith('/board')) return AppTab.board;
    return AppTab.storage;
  }
}

enum AppBarSize { normal, medium }

/// 通用的 [Scaffold]，body 为 [CustomScrollView]
class MySliverScaffold extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final Widget? sliver;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? navigationRail;
  final Widget? drawer;
  final double contentMaxWidth;
  final PreferredSizeWidget? appbarBottom;
  final Future<void> Function()? onRefresh;
  final AppBarSize appBarSize;
  final bool Function()? canPop;
  final void Function(bool, Object?)? onPopInvokedWithResult;

  const MySliverScaffold({
    super.key,
    required this.title,
    this.actions,
    this.sliver,
    this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.navigationRail,
    this.drawer,
    this.contentMaxWidth = AppBreakpoints.contentMaxWidth,
    this.onRefresh,
    this.appbarBottom,
    this.appBarSize = AppBarSize.medium,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = PopScope(
      canPop: canPop == null ? true : canPop!(),
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: ConditionalParentWidget(
        condition: onRefresh != null,
        conditionalBuilder: (child) {
          return RefreshIndicator(
            edgeOffset: 56,
            onRefresh: () async {
              await onRefresh!();
            },
            child: child,
          );
        },
        child: CustomScrollView(
          slivers: <Widget>[
            if (appBarSize == AppBarSize.normal || appbarBottom != null)
              SliverAppBar(
                title: title,
                actions: actions,
                bottom: appbarBottom,
                pinned: true,
              )
            else
              SliverAppBar.medium(title: title, actions: actions),
            ?sliver,
            ...?slivers,
          ],
        ),
      ),
    );

    // 宽屏下内容限宽并居中，否则表单和列表会被拉满整块屏幕
    body = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        child: body,
      ),
    );
    if (navigationRail != null) {
      body = Row(
        children: <Widget>[
          navigationRail!,
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      drawer: drawer,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
