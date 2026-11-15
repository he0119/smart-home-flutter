import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/widgets/scan_qr_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/state_views.dart';

class StorageHomePage extends StatelessWidget {
  const StorageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageHomeScreen();
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
          title: AppTab.storage.name,
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
        SliverErrorState(
          onRetry: () {
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
            child: EntryRow(
              icon: Icons.storage,
              title: '所有位置',
              supporting: '全部位置和物品',
              onTap: () {
                context.goStorageDetail(homeStorage.id);
              },
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
      final hasAnyItem = <List<Item>?>[
        state.expiredItems,
        state.nearExpiredItems,
        state.recentlyEditedItems,
        state.recentlyCreatedItems,
      ].any((items) => items?.isNotEmpty ?? false);
      if (!hasAnyItem) {
        listofWidget.add(
          const SliverEmptyState(
            icon: Icons.inventory_2_outlined,
            title: '还没有物品',
            message: '点右下角的 + 添加第一个物品',
          ),
        );
      }
    } else if (state.status == StorageHomeStatus.loading) {
      listofWidget.add(const SliverCenterLoadingIndicator());
    }
    if (state.status == StorageHomeStatus.success) {
      listofWidget.add(const SliverToBoxAdapter(child: ListBottomPadding()));
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
        color: Theme.of(context).colorScheme.surface,
        child: SectionHeader(
          title: headerText,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          action: IconButton(
            tooltip: currentType == ItemType.all ? '展开全部' : '收起',
            visualDensity: VisualDensity.compact,
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
        ),
      ),
      sliver: SliverInfiniteList<Item>(
        items: items,
        separatorBuilder: (context, item) => const ContentDivider(),
        itemBuilder: (context, item) {
          return _buildItemRow(context, item, listType);
        },
        hasReachedMax: hasReachedMax,
        onFetch: () {
          ref.read(storageHomeProvider.notifier).fetch(itemType: currentType);
        },
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, Item item, ItemType type) {
    final time = switch (type) {
      ItemType.expired ||
      ItemType.nearExpired => item.expiredAt!.differenceFromNowStr(),
      ItemType.recentlyCreated => item.createdAt!.differenceFromNowStr(),
      ItemType.recentlyEdited => item.editedAt!.differenceFromNowStr(),
      ItemType.all => '',
    };
    // 副标题优先放备注，没有备注再退到位置名；时间放在尾部，
    // 这样「最近修改」分组里的时间一眼能看到，也不挤掉原来的备注
    final description = item.description;
    final storageName = item.storage?.name;
    final supporting = (description != null && description.isNotEmpty)
        ? description
        : storageName;

    return ContentRow(
      icon: Icons.inventory_2_outlined,
      title: Text(item.name),
      supporting: supporting == null || supporting.isEmpty
          ? null
          : Text(supporting),
      trailing: time.isEmpty
          ? null
          : Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      onTap: () async {
        context.goItemDetail(item.id);
      },
    );
  }
}
