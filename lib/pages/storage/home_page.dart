import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smarthome/blocs/storage/blocs.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/pages/storage/widgets/search_icon_button.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class StorageHomePage extends Page {
  StorageHomePage()
      : super(
          key: ValueKey('storage'),
          name: '/storage',
        );

  @override
  Route createRoute(BuildContext context) {
    BlocProvider.of<StorageHomeBloc>(context)
        .add(StorageHomeFetched(itemType: ItemType.all));
    return MaterialPageRoute(
      settings: this,
      builder: (context) => StorageHomeScreen(),
    );
  }
}

class StorageHomeScreen extends StatelessWidget {
  const StorageHomeScreen({Key? key}) : super(key: key);

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
          MyRouterDelegate.of(context).addStorageGroup();
        },
      ),
    );
  }
}

class _StorageHomeBody extends StatelessWidget {
  const _StorageHomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageHomeBloc, StorageHomeState>(
      builder: (context, state) {
        if (state is StorageHomeFailure) {
          return ErrorMessageButton(
            onPressed: () {
              BlocProvider.of<StorageHomeBloc>(context).add(
                StorageHomeFetched(
                  itemType: state.itemType,
                  cache: false,
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
                  .add(StorageHomeFetched(itemType: ItemType.all));
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StorageHomeBloc>(context)
                    .add(StorageHomeFetched(
                  itemType: state.itemType,
                  cache: false,
                ));
              },
              child: SliverInfiniteList<List<Item>>(
                key: ValueKey(state.itemType),
                slivers: _buildSlivers(context, state),
                hasReachedMax: state.hasReachedMax,
                itemCount: state.itemCount,
                onFetch: () {
                  BlocProvider.of<StorageHomeBloc>(context)
                      .add(StorageHomeFetched(
                    itemType: state.itemType,
                  ));
                },
              ),
            ),
          );
        }
        return CenterLoadingIndicator();
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, StorageHomeSuccess state) {
    List<Widget> listofWidget = [];
    if (state.expiredItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverList(
          context, state.expiredItems, ItemType.expired, state.itemType));
    }
    if (state.nearExpiredItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverList(context, state.nearExpiredItems,
          ItemType.nearExpired, state.itemType));
    }
    if (state.recentlyEditedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverList(context, state.recentlyEditedItems,
          ItemType.recentlyEdited, state.itemType));
    }
    if (state.recentlyCreatedItems?.isNotEmpty ?? false) {
      listofWidget.add(_buildSliverList(context, state.recentlyCreatedItems,
          ItemType.recentlyCreated, state.itemType));
    }
    return listofWidget;
  }

  SliverList _buildSliverList(
    BuildContext context,
    List<Item>? items,
    ItemType listType,
    ItemType currentType,
  ) {
    late String headerText;
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => index == 0
            ? Container(
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
                          StorageHomeFetched(
                              itemType: currentType != ItemType.all
                                  ? ItemType.all
                                  : listType),
                        );
                      },
                    )
                  ],
                ),
              )
            : _buildItemListItem(
                context, items![index - 1], listType, currentType),
        childCount: items!.length + 1,
      ),
    );
  }

  ListTile _buildItemListItem(
    BuildContext context,
    Item item,
    ItemType type,
    ItemType currentType,
  ) {
    String? differenceText;
    switch (type) {
      case ItemType.expired:
      case ItemType.nearExpired:
        differenceText = '（${item.expiredAt!.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyCreated:
        differenceText = '（${item.createdAt!.differenceFromNowStr()}）';
        break;
      case ItemType.recentlyEdited:
        differenceText = '（${item.editedAt!.differenceFromNowStr()}）';
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
        MyRouterDelegate.of(context).addItemPage(item: item);
      },
    );
  }
}
