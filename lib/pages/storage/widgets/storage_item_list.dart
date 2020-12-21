import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/widgets/bottom_loader.dart';

class StorageItemList extends StatefulWidget {
  final List<Item> items;
  final List<Storage> storages;
  final String term;
  final bool isHighlight;
  final bool hasNextPage;
  final VoidCallback onFetch;

  const StorageItemList({
    Key key,
    this.items,
    this.storages,
    this.term = '',
    this.isHighlight = false,
    this.hasNextPage = false,
    this.onFetch,
  })  : assert(hasNextPage != null),
        super(key: key);

  @override
  _StorageItemListState createState() => _StorageItemListState();
}

class _StorageItemListState extends State<StorageItemList> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(widget.storages)..addAll(widget.items);
    return Scrollbar(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.hasNextPage ? merged.length + 1 : merged.length,
        itemBuilder: (BuildContext context, int index) {
          if (index >= merged.length) {
            return BottomLoader();
          }
          if (widget.isHighlight) {
            return _HighlightStorageItemListItem(
              item: merged[index],
              term: widget.term,
            );
          } else {
            return _StorageItemListItem(item: merged[index]);
          }
        },
        separatorBuilder: (contexit, index) => Divider(),
        controller: _scrollController,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold && widget.hasNextPage) {
      widget.onFetch();
    }
  }
}

/// 位置详情界面使用的列表
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
              builder: (_) => ItemDetailPage(
                itemId: item.id,
                storageDetailBloc: BlocProvider.of<StorageDetailBloc>(context),
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
                itemId: item.id,
                storageSearchBloc: BlocProvider.of<StorageSearchBloc>(context),
                searchKeyword: term,
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
