import 'package:flutter/material.dart';
import 'package:smarthome/core/router/router_extensions.dart';
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
    super.key,
    this.items,
    this.storages,
    this.term = '',
    this.isHighlight = false,
    this.hasReachedMax = true,
    this.onFetch,
  });

  @override
  Widget build(BuildContext context) {
    final merged = List<dynamic>.from(storages!)..addAll(items!);
    return SliverInfiniteList(
      items: merged,
      itemBuilder: (context, dynamic item) {
        if (isHighlight) {
          return _HighlightStorageItemListItem(item: item, term: term);
        } else {
          return _StorageItemListItem(item: item);
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

  const _HighlightStorageItemListItem({required this.item, required this.term});

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(Icons.insert_drive_file, size: 34.0),
        title: SubstringHighlight(text: item.name, term: term),
        subtitle: SubstringHighlight(text: item.description ?? '', term: term),
        onTap: () {
          context.goItemDetail(item.id);
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.storage, size: 34.0),
        title: SubstringHighlight(text: item.name, term: term),
        subtitle: SubstringHighlight(text: item.description ?? '', term: term),
        onTap: () async {
          context.goStorageDetail(item.id);
        },
      );
    }
  }
}

/// 位置详情界面使用的列表
class _StorageItemListItem extends StatelessWidget {
  final dynamic item;

  const _StorageItemListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(Icons.insert_drive_file, size: 34.0),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          context.goItemDetail(item.id);
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.storage, size: 34.0),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          context.goStorageDetail(item.id);
        },
      );
    }
  }
}
