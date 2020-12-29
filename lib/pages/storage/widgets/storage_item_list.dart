import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/widgets/infinite_list.dart';
import 'package:substring_highlight/substring_highlight.dart';

class StorageItemList extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;
  final String term;
  final bool isHighlight;
  final bool hasReachedMax;
  final VoidCallback onFetch;

  const StorageItemList({
    Key key,
    this.items,
    this.storages,
    this.term = '',
    this.isHighlight = false,
    this.hasReachedMax = true,
    this.onFetch,
  })  : assert(hasReachedMax != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(storages)..addAll(items);
    return InfiniteList(
      items: merged,
      itemBuilder: (context, item) {
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
    Key key,
    @required this.item,
    @required this.term,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(context).style;
    final TextStyle highlightStyle = style.merge(TextStyle(color: Colors.red));
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: SubstringHighlight(
          text: item.name,
          term: term,
          textStyle: style,
          textStyleHighlight: highlightStyle,
        ),
        subtitle: SubstringHighlight(
          text: item.description ?? '',
          term: term,
          textStyle: style,
          textStyleHighlight: highlightStyle,
        ),
        onTap: () {
          MyRouterDelegate.of(context).addItemPage(item: item);
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
          textStyle: style,
          textStyleHighlight: highlightStyle,
        ),
        subtitle: SubstringHighlight(
          text: item.description ?? '',
          term: term,
          textStyle: style,
          textStyleHighlight: highlightStyle,
        ),
        onTap: () async {
          MyRouterDelegate.of(context).addStorageGroup(storage: item);
        },
      );
    }
  }
}

/// 位置详情界面使用的列表
class _StorageItemListItem extends StatelessWidget {
  final dynamic item;

  const _StorageItemListItem({
    Key key,
    @required this.item,
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
          MyRouterDelegate.of(context).addItemPage(item: item);
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
          MyRouterDelegate.of(context).setStoragePage(storage: item);
        },
      );
    }
  }
}
