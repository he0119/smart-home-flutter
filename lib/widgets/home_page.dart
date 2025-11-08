import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/conditional_parent_widget.dart';
import 'package:smarthome/widgets/drawer.dart';
import 'package:smarthome/widgets/tab_selector.dart';

class MyHomePage extends StatelessWidget {
  final AppTab activeTab;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final bool Function()? canPop;
  final void Function(bool, Object?)? onPopInvokedWithResult;

  const MyHomePage({
    super.key,
    required this.activeTab,
    this.actions,
    this.slivers,
    this.floatingActionButton,
    this.onRefresh,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      title: Text(activeTab.name),
      actions: actions,
      slivers: slivers,
      drawer: const MyDrawer(),
      floatingActionButton: floatingActionButton,
      onRefresh: onRefresh,
      bottomNavigationBar: TabSelector(
        activeTab: activeTab,
        onTabSelected: (tab) =>
            BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
      ),
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
    );
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
  final Widget? drawer;
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
    this.drawer,
    this.onRefresh,
    this.appbarBottom,
    this.appBarSize = AppBarSize.medium,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      body: PopScope(
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
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
