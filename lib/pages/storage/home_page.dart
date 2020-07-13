import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:smart_home/blocs/authentication/authentication_bloc.dart';
import 'package:smart_home/blocs/storage/storage_home/storage_home_bloc.dart';
import 'package:smart_home/blocs/tab/tab_bloc.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/gravatar.dart';
import 'package:smart_home/widgets/tab_selector.dart';

class StorageHomePage extends StatelessWidget {
  const StorageHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: state is Authenticated
              ? IconButton(
                  icon: CircleGravatar(email: state.currentUser.email),
                  onPressed: null,
                )
              : null,
          title: Text('物品管理'),
          actions: <Widget>[
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
        ),
        body: _StorageHomeBody(),
        bottomNavigationBar: TabSelector(
          activeTab: AppTab.storage,
          onTabSelected: (tab) =>
              BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.storage),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StorageDetailPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StorageHomeBody extends StatelessWidget {
  const _StorageHomeBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageHomeBloc, StorageHomeState>(
      builder: (context, state) {
        if (state is StorageHomeInProgress) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is StorageHomeError) {
          return Center(child: Text(state.message));
        }
        if (state is StorageHomeSuccess) {
          // 从各种类型详情页返回
          return WillPopScope(
            onWillPop: () async {
              if (state.itemType == ItemType.all) {
                return true;
              }
              BlocProvider.of<StorageHomeBloc>(context)
                  .add(StorageHomeRefreshed(itemType: ItemType.all));
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StorageHomeBloc>(context)
                    .add(StorageHomeRefreshed(itemType: state.itemType));
              },
              child: CustomScrollView(
                key: ValueKey(state.itemType),
                slivers: _buildSlivers(context, state),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, StorageHomeSuccess state) {
    List<Widget> listofWidget = [];
    if (state.expiredItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(
          context, state.expiredItems, ItemType.expired, state.itemType));
    }
    if (state.nearExpiredItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(context, state.nearExpiredItems,
          ItemType.nearExpired, state.itemType));
    }
    if (state.recentlyUpdatedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(
          context,
          state.recentlyUpdatedItems,
          ItemType.recentlyUpdated,
          state.itemType));
    }
    if (state.recentlyAddedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(context,
          state.recentlyAddedItems, ItemType.recentlyAdded, state.itemType));
    }
    return listofWidget;
  }

  SliverStickyHeader _buildSliverStickyHeader(BuildContext context,
      List<Item> items, ItemType listType, ItemType currentType) {
    String headerText;
    switch (listType) {
      case ItemType.expired:
        headerText = '过期物品';
        break;
      case ItemType.nearExpired:
        headerText = '即将过期';
        break;
      case ItemType.recentlyAdded:
        headerText = '最近添加';
        break;
      case ItemType.recentlyUpdated:
        headerText = '最近更新';
        break;
      case ItemType.all:
        break;
    }
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text(
              headerText,
              style: DefaultTextStyle.of(context).style,
            ),
            Spacer(),
            IconButton(
              icon: Icon(currentType == ItemType.all
                  ? Icons.expand_more
                  : Icons.expand_less),
              onPressed: () {
                BlocProvider.of<StorageHomeBloc>(context).add(
                  StorageHomeChanged(
                      itemType: currentType != ItemType.all
                          ? ItemType.all
                          : listType),
                );
              },
            )
          ],
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) =>
              _buildItemListItem(context, items[index], listType),
          childCount: items.length,
        ),
      ),
    );
  }

  ListTile _buildItemListItem(BuildContext context, Item item, ItemType type) {
    String differenceText;
    switch (type) {
      case ItemType.expired:
      case ItemType.nearExpired:
        differenceText = '（${item.expirationDate.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyAdded:
        differenceText = '（${item.dateAdded.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyUpdated:
        differenceText = '（${item.updateDate.differenceFromNowStr()}）';
        break;
      case ItemType.all:
        break;
    }
    final text = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: item.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: differenceText,
          ),
        ],
      ),
    );
    return ListTile(
      title: text,
      subtitle: Text(item.description ?? ''),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailPage(
              itemId: item.id,
              storageHomeBloc: BlocProvider.of<StorageHomeBloc>(context),
            ),
          ),
        );
      },
    );
  }
}
