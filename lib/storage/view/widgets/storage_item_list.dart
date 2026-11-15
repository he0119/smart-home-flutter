import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/substring_highlight.dart';

/// 物品 / 位置混排的列表，位置详情和搜索页都用它。
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
      separatorBuilder: (context, item) => const ContentDivider(),
      itemBuilder: (context, dynamic item) {
        if (isHighlight) {
          return _HighlightRow(item: item, term: term);
        }
        return _ContentItemRow(item: item);
      },
      hasReachedMax: hasReachedMax,
      onFetch: onFetch,
    );
  }
}

/// 搜索页的列表行：标题和副标题都带关键字高亮，并标出物品所在位置。
class _HighlightRow extends StatelessWidget {
  final dynamic item;
  final String term;

  const _HighlightRow({required this.item, required this.term});

  @override
  Widget build(BuildContext context) {
    final isItem = item is Item;
    final description = (item.description as String?) ?? '';
    final where = isItem ? (item as Item).storage?.name : null;
    // 位置名和描述拼成一条副标题，统一参与关键字高亮
    final supporting = <String>[
      if (where != null && where.isNotEmpty) where,
      if (description.isNotEmpty) description,
    ].join(' · ');

    return ContentRow(
      icon: isItem ? Icons.inventory_2_outlined : Icons.folder_outlined,
      title: SubstringHighlight(text: item.name as String, term: term),
      supporting: supporting.isEmpty
          ? null
          : SubstringHighlight(text: supporting, term: term),
      onTap: () {
        if (isItem) {
          context.goItemDetail(item.id);
        } else {
          context.goStorageDetail(item.id);
        }
      },
    );
  }
}

/// 位置详情里的普通行。
class _ContentItemRow extends StatelessWidget {
  final dynamic item;

  const _ContentItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isItem = item is Item;
    final description = (item.description as String?) ?? '';
    return ContentRow(
      icon: isItem ? Icons.inventory_2_outlined : Icons.folder_outlined,
      title: Text(item.name as String),
      supporting: description.isEmpty ? null : Text(description),
      onTap: () {
        if (isItem) {
          context.goItemDetail(item.id);
        } else {
          context.goStorageDetail(item.id);
        }
      },
    );
  }
}
