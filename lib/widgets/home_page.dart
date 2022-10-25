import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/drawer.dart';
import 'package:smarthome/widgets/tab_selector.dart';

class MyHomePage extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floatingActionButton;
  final AppTab activeTab;
  final List<Widget>? slivers;

  const MyHomePage({
    Key? key,
    required this.activeTab,
    this.body,
    this.actions,
    this.floatingActionButton,
    this.slivers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (slivers != null) {
      return Scaffold(
        drawer: const MyDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(activeTab.title),
              actions: actions,
            ),
            ...slivers!,
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: TabSelector(
          activeTab: activeTab,
          onTabSelected: (tab) =>
              BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      assert(body != null); // body must not be null if slivers is null
      return Scaffold(
        drawer: const MyDrawer(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar.medium(
                title: Text(activeTab.title),
                actions: actions,
              ),
            ];
          },
          body: body!,
        ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: TabSelector(
          activeTab: activeTab,
          onTabSelected: (tab) =>
              BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
        ),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
