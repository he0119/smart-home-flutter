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
  final Future<bool> Function()? onWillPop;

  const MyHomePage({
    super.key,
    required this.activeTab,
    this.actions,
    this.slivers,
    this.floatingActionButton,
    this.onRefresh,
    this.onWillPop,
  });

  @override
  Widget build(BuildContext context) {
    return MySliverPage(
      title: activeTab.name,
      actions: actions,
      slivers: slivers,
      drawer: const MyDrawer(),
      floatingActionButton: floatingActionButton,
      onRefresh: onRefresh,
      onWillPop: onWillPop,
      bottomNavigationBar: TabSelector(
        activeTab: activeTab,
        onTabSelected: (tab) =>
            BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
      ),
    );
  }
}

class MySliverPage extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final Widget? sliver;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Future<void> Function()? onRefresh;
  final Future<bool> Function()? onWillPop;

  const MySliverPage({
    super.key,
    required this.title,
    this.actions,
    this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.onRefresh,
    this.onWillPop,
    this.sliver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      body: WillPopScope(
        onWillPop: onWillPop,
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
              SliverAppBar.medium(
                title: Text(title),
                actions: actions,
              ),
              if (sliver != null) sliver!,
              if (slivers != null) ...slivers!,
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
