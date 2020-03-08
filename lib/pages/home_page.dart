import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_add_edit_page.dart';
import 'package:smart_home/widgets/tab_selector.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        return Scaffold(
          appBar: _AppBar(),
          body: _HomePageBody(),
          bottomNavigationBar: TabSelector(
            activeTab: activeTab,
            onTabSelected: (tab) =>
                BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
          ),
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.iot) {
          return AppBar(
            title: Text('IOT'),
          );
        }
        if (activeTab == AppTab.storage) {
          return AppBar(
            title: Text('物品管理'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StorageAddEditStoagePage(
                        isEditing: false,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchPage()),
                  );
                },
              ),
            ],
          );
        }
        return AppBar(title: Text('留言板'));
      },
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.iot) {
          return Center(
            child: Text(
              'Index 0: IOT',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          );
        }
        if (activeTab == AppTab.storage) {
          return StorageHomePage();
        }
        return Center(
          child: Text(
            'Index 2: 留言板',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
