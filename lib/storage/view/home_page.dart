import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/widgets/scan_qr_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class StorageHomePage extends Page {
  const StorageHomePage()
    : super(key: const ValueKey('storage'), name: '/storage');

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => FadeTransition(
            opacity: animation,
            child: const StorageHomeScreen(),
          ),
    );
  }
}

class StorageHomeScreen extends ConsumerWidget {
  const StorageHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storageHomeProvider);
    return Consumer(
      builder: (context, ref, child) {
        return MyHomePage(
          activeTab: AppTab.storage,
          actions: <Widget>[
            // 仅支持网页和安卓
            if (kIsWeb || Platform.isAndroid) const ScanQRIconButton(),
            const SearchIconButton(),
          ],
          floatingActionButton: FloatingActionButton(
            tooltip: '添加物品',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ItemEditPage(isEditing: false),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          slivers: _buildSlivers(context, ref, state),
          onRefresh: (state.status == StorageHomeStatus.success)
              ? () async {
                  ref
                      .read(storageHomeProvider.notifier)
                      .fetch(itemType: state.itemType, cache: false);
                }
              : null,
          canPop: () {
            return state.status == StorageHomeStatus.success &&
                state.itemType == ItemType.all;
          },
          onPopInvokedWithResult: (didPop, result) {
            if (state.status == StorageHomeStatus.success) {
              ref
                  .read(storageHomeProvider.notifier)
                  .fetch(itemType: ItemType.all);
            }
          },
        );
      },
    );
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    WidgetRef ref,
    StorageHomeState state,
  ) {
    List<Widget> listofWidget = [];

    if (state.status == StorageHomeStatus.failure) {
      listofWidget.add(
        SliverErrorMessageButton(
          onPressed: () {
            ref
                .read(storageHomeProvider.notifier)
                .fetch(itemType: state.itemType, cache: false);
          },
          message: state.errorMessage,
        ),
      );
    } else if (state.status == StorageHomeStatus.success) {
      // 仅在主界面添加所有位置按钮
      if (state.itemType == ItemType.all) {
        listofWidget.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: InkWell(
                onTap: () {
                  MyRouterDelegate.of(
                    context,
                  ).push(StorageDetailPage(storageId: homeStorage.id));
                },
                child: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: ListTile(
                    title: Text(
                      '所有位置',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.storage,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (state.expiredItems?.isNotEmpty ?? false) {
        listofWidget.add(
          _buildSliverStickyHeader(
            context,
            ref,
            state.expiredItems!,
            ItemType.expired,
            state.itemType,
            state.hasReachedMax,
          ),
        );
      }
      if (state.nearExpiredItems?.isNotEmpty ?? false) {
        listofWidget.add(
          _buildSliverStickyHeader(
            context,
            ref,
            state.nearExpiredItems!,
            ItemType.nearExpired,
            state.itemType,
            state.hasReachedMax,
          ),
        );
      }
      if (state.recentlyEditedItems?.isNotEmpty ?? false) {
        listofWidget.add(
          _buildSliverStickyHeader(
            context,
            ref,
            state.recentlyEditedItems!,
            ItemType.recentlyEdited,
            state.itemType,
            state.hasReachedMax,
          ),
        );
      }
      if (state.recentlyCreatedItems?.isNotEmpty ?? false) {
        listofWidget.add(
          _buildSliverStickyHeader(
            context,
            ref,
            state.recentlyCreatedItems!,
            ItemType.recentlyCreated,
            state.itemType,
            state.hasReachedMax,
          ),
        );
      }
    } else if (state.status == StorageHomeStatus.loading) {
      listofWidget.add(const SliverCenterLoadingIndicator());
    }
    return listofWidget;
  }

  Widget _buildSliverStickyHeader(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    ItemType listType,
    ItemType currentType,
    bool hasReachedMax,
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
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text(headerText),
            const Spacer(),
            IconButton(
              icon: Icon(
                currentType == ItemType.all
                    ? Icons.expand_more
                    : Icons.expand_less,
              ),
              onPressed: () {
                ref
                    .read(storageHomeProvider.notifier)
                    .fetch(
                      itemType: currentType != ItemType.all
                          ? ItemType.all
                          : listType,
                    );
              },
            ),
          ],
        ),
      ),
      sliver: SliverInfiniteList<Item>(
        items: items,
        itemBuilder: (context, item) {
          return _buildItemListItem(context, item, listType, currentType);
        },
        hasReachedMax: hasReachedMax,
        onFetch: () {
          ref.read(storageHomeProvider.notifier).fetch(itemType: currentType);
        },
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: differenceText),
        ],
      ),
    );
    return ListTile(
      title: text,
      subtitle: Text(item.description ?? ''),
      onTap: () async {
        MyRouterDelegate.of(context).push(ItemDetailPage(itemId: item.id));
      },
    );
  }
}
