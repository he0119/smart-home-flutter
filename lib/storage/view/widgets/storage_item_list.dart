import 'package:flutter/material.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/substring_highlight.dart';

class StorageItemList extends StatelessWidget {
  final List<Item>? items;
  final List<Storage>? storages;
  final String term;
  final bool isHighlight;
  final bool hasReachedMax;
  final VoidCallback? onFetch;

  const StorageItemList({
    Key? key,
    this.items,
    this.storages,
    this.term = '',
    this.isHighlight = false,
    this.hasReachedMax = true,
    this.onFetch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merged = List<dynamic>.from(storages!)..addAll(items!);
    return InfiniteList(
      items: merged,
      itemBuilder: (context, dynamic item) {
        if (isHighlight) {
          return _HighlightStorageItemListItem(
            item: item,
            term: term,
          );
        } else {
          return _StorageItemListItem(
            item: item,
          );
        }
      },
      hasReachedMax: hasReachedMax,
      onFetch: onFetch,
    );
  }
}

/// 搜索界面使用的列表
class _HighlightStorageItemListItem extends StatelessWidget {
  final dynamic item;
  final String term;

  const _HighlightStorageItemListItem({
    Key? key,
    required this.item,
    required this.term,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: SubstringHighlight(
          text: item.name,
          term: term,
        ),
        subtitle: SubstringHighlight(
          text: item.description ?? '',
          term: term,
        ),
        onTap: () {
          MyRouterDelegate.of(context).push(ItemDetailPage(itemId: item.id));
        },
      );
    } else {
      return ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: SubstringHighlight(
          text: item.name,
          term: term,
        ),
        subtitle: SubstringHighlight(
          text: item.description ?? '',
          term: term,
        ),
        onTap: () async {
          MyRouterDelegate.of(context)
              .push(StorageDetailPage(storageId: item.id));
        },
      );
    }
  }
}

/// 位置详情界面使用的列表
class _StorageItemListItem extends StatelessWidget {
  final dynamic item;

  const _StorageItemListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          MyRouterDelegate.of(context).push(ItemDetailPage(itemId: item.id));
        },
      );
    } else {
      return ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          MyRouterDelegate.of(context)
              .push(StorageDetailPage(storageId: item.id));
        },
      );
    }
  }
}
