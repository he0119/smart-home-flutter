import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/pages/storage/widgets/search_icon_button.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/widgets/home_page.dart';

class StorageHomePage extends StatelessWidget {
  const StorageHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      activeTab: AppTab.storage,
      actions: <Widget>[
        SearchIconButton(),
      ],
      body: _StorageHomeBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: '所有位置',
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
    );
  }
}

class _StorageHomeBody extends StatelessWidget {
  const _StorageHomeBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageHomeBloc, StorageHomeState>(
      builder: (context, state) {
        if (state is StorageHomeFailure) {
          return ErrorPage(
            onPressed: () {
              BlocProvider.of<StorageHomeBloc>(context).add(
                StorageHomeChanged(
                  itemType: state.itemType,
                  refresh: true,
                ),
              );
            },
            message: state.message,
          );
        }
        if (state is StorageHomeSuccess) {
          // 从各种类型详情页返回
          return WillPopScope(
            onWillPop: () async {
              if (state.itemType == ItemType.all) {
                return true;
              }
              BlocProvider.of<StorageHomeBloc>(context)
                  .add(StorageHomeChanged(itemType: ItemType.all));
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StorageHomeBloc>(context)
                    .add(StorageHomeChanged(
                  itemType: state.itemType,
                  refresh: true,
                ));
              },
              child: CustomScrollView(
                key: ValueKey(state.itemType),
                slivers: _buildSlivers(context, state),
              ),
            ),
          );
        }
        return LoadingPage();
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
    if (state.recentlyEditedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(context,
          state.recentlyEditedItems, ItemType.recentlyEdited, state.itemType));
    }
    if (state.recentlyCreatedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverStickyHeader(
          context,
          state.recentlyCreatedItems,
          ItemType.recentlyCreated,
          state.itemType));
    }
    return listofWidget;
  }

  SliverStickyHeader _buildSliverStickyHeader(
    BuildContext context,
    List<Item> items,
    ItemType listType,
    ItemType currentType,
  ) {
    String headerText;
    switch (listType) {
      case ItemType.expired:
        headerText = '过期物品';
        break;
      case ItemType.nearExpired:
        headerText = '即将过期';
        break;
      case ItemType.recentlyCreated:
        headerText = '最近录入';
        break;
      case ItemType.recentlyEdited:
        headerText = '最近修改';
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
              _buildItemListItem(context, items[index], listType, currentType),
          childCount: items.length,
        ),
      ),
    );
  }

  ListTile _buildItemListItem(
    BuildContext context,
    Item item,
    ItemType type,
    ItemType currentType,
  ) {
    String differenceText;
    switch (type) {
      case ItemType.expired:
      case ItemType.nearExpired:
        differenceText = '（${item.expiredAt.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyCreated:
        differenceText = '（${item.createdAt.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyEdited:
        differenceText = '（${item.editedAt.differenceFromNowStr()}）';
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
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailPage(
              itemId: item.id,
            ),
          ),
        );
        BlocProvider.of<StorageHomeBloc>(context)
            .add(StorageHomeChanged(itemType: currentType));
      },
    );
  }
}
