import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/widgets/drawer.dart';
import 'package:smart_home/widgets/tab_selector.dart';

class MyHomePage extends StatelessWidget {
  final List<Widget> actions;
  final Widget body;
  final Widget floatingActionButton;
  final AppTab activeTab;

  const MyHomePage({
    @required this.activeTab,
    @required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(activeTab.title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: TabSelector(
        activeTab: activeTab,
        onTabSelected: (tab) =>
            BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
