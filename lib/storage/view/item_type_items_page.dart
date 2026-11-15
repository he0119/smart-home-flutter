import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/item_type_items_provider.dart';
import 'package:smarthome/storage/view/widgets/item_row.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/state_views.dart';

/// 某一类物品的完整列表。首页分组只显示第一页，点「全部」进这里翻到底。
class ItemTypeItemsPage extends ConsumerWidget {
  final ItemType itemType;

  const ItemTypeItemsPage({super.key, required this.itemType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemTypeItemsProvider(itemType);
    final state = ref.watch(provider);

    return MySliverScaffold(
      appBarSize: AppBarSize.normal,
      title: Text(itemType.sectionTitle),
      onRefresh: () async {
        await ref.read(provider.notifier).fetch(cache: false);
      },
      slivers: <Widget>[
        if (state.status == ItemTypeItemsStatus.failure)
          SliverErrorState(
            message: state.errorMessage,
            onRetry: () {
              ref.read(provider.notifier).fetch(cache: false);
            },
          ),
        if (state.status == ItemTypeItemsStatus.loading ||
            state.status == ItemTypeItemsStatus.initial)
          const SliverCenterLoadingIndicator(),
        if (state.status == ItemTypeItemsStatus.success && state.items.isEmpty)
          SliverEmptyState(
            icon: Icons.inventory_2_outlined,
            title: '这一类还没有物品',
            message: '换个分类看看，或者回首页添加物品',
          ),
        if (state.status == ItemTypeItemsStatus.success &&
            state.items.isNotEmpty)
          SliverInfiniteList<Item>(
            items: state.items,
            separatorBuilder: (context, item) => const ContentDivider(),
            itemBuilder: (context, item) => ItemRow(item: item, type: itemType),
            hasReachedMax: state.hasReachedMax,
            onFetch: () {
              ref.read(provider.notifier).fetchMore();
            },
          ),
        if (state.status == ItemTypeItemsStatus.success)
          const SliverToBoxAdapter(child: ListBottomPadding(height: 24)),
      ],
    );
  }
}
