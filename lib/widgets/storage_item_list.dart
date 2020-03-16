import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/blocs/storage/storage_detail/storage_detail_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:substring_highlight/substring_highlight.dart';

class StorageItemList extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;
  final String term;
  final bool isHighlight;

  const StorageItemList({
    Key key,
    this.items,
    this.storages,
    this.term = '',
    this.isHighlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(items)..addAll(storages);
    return ListView.separated(
      itemCount: merged.length,
      itemBuilder: (BuildContext context, int index) {
        if (isHighlight) {
          return _HighlightStorageItemListItem(
            item: merged[index],
            term: term,
          );
        } else {
          return _StorageItemListItem(item: merged[index]);
        }
      },
      separatorBuilder: (contexit, index) => Divider(),
    );
  }
}

/// 物品详情界面使用的列表
class _StorageItemListItem extends StatelessWidget {
  final dynamic item;

  const _StorageItemListItem({Key key, @required this.item}) : super(key: key);

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
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(isAdding: false, itemId: item.id),
            ),
          );
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
          BlocProvider.of<StorageDetailBloc>(context)
              .add(StorageDetailChanged(id: item.id));
        },
      );
    }
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(
                isAdding: false,
                itemId: item.id,
                searchKeyword: term,
                storageSearchBloc: BlocProvider.of<StorageSearchBloc>(context),
              ),
            ),
          );
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StorageDetailPage(storageId: item.id)),
          );
        },
      );
    }
  }
}

class SliverStorageItemList extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;

  const SliverStorageItemList({Key key, this.items, this.storages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(items)..addAll(storages);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildListTile(context, merged[index]);
        },
        childCount: merged.length,
      ),
    );
  }

  ListTile _buildListTile(BuildContext context, dynamic item) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () async {
          String storageId = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    ItemDetailPage(isAdding: false, itemId: item.id)),
          );
          if (storageId != null) {
            BlocProvider.of<StorageDetailBloc>(context)
                .add(StorageDetailRefreshed(id: storageId));
          }
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
          BlocProvider.of<StorageDetailBloc>(context)
              .add(StorageDetailChanged(id: item.id));
        },
      );
    }
  }
}
