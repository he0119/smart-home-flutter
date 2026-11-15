import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/item_edit_provider.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/dropdown_search.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class ConsumableEditPage extends ConsumerStatefulWidget {
  final Item item;

  const ConsumableEditPage({super.key, required this.item});

  @override
  ConsumerState<ConsumableEditPage> createState() => _ConsumableEditPageState();
}

class _ConsumableEditPageState extends ConsumerState<ConsumableEditPage> {
  Item? selectedItem;
  late Item current;

  @override
  void initState() {
    super.initState();
    current = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemEditProvider);

    // Listen to state changes
    ref.listen<ItemEditState>(itemEditProvider, (previous, next) {
      if (next.status == ItemEditStatus.consumableAddSuccess) {
        showInfoSnackBar('耗材添加成功');
        if (next.item != null) {
          setState(() {
            current = next.item!;
          });
        }
      }
      if (next.status == ItemEditStatus.consumableDeleteSuccess) {
        showInfoSnackBar('耗材删除成功');
        if (next.item != null) {
          setState(() {
            current = next.item!;
          });
        }
      }
      if (next.status == ItemEditStatus.failure) {
        showErrorSnackBar(next.errorMessage);
      }
    });

    return MySliverScaffold(
      appBarSize: AppBarSize.normal,
      title: const Text('耗材编辑'),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SectionHeader(
              title: '已添加的耗材',
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            ),
            if (current.consumables!.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  '还没有耗材，在下面选一个物品加进来',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (var i = 0; i < current.consumables!.length; i++) ...<Widget>[
              ContentRow(
                icon: Icons.inventory_2_outlined,
                title: Text(current.consumables![i].name),
                trailing: IconButton(
                  tooltip: '移除耗材',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref
                        .read(itemEditProvider.notifier)
                        .deleteConsumable(
                          item: widget.item,
                          consumables: [current.consumables![i]],
                        );
                    showInfoSnackBar('正在删除...', duration: 1);
                  },
                ),
              ),
              if (i < current.consumables!.length - 1) const ContentDivider(),
            ],
            const Divider(),
            const SectionHeader(
              title: '添加耗材',
              padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: MyDropdownSearch(
                label: '耗材',
                items: (text) async {
                  final storageRepository = ref.read(storageRepositoryProvider);
                  final items = await storageRepository.items(
                    key: text,
                    cache: false,
                  );
                  return items;
                },
                showClearButton: true,
                onSelected: (Item? value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: RoundedRaisedButton(
                  onPressed:
                      (state.status != ItemEditStatus.loading &&
                          selectedItem != null)
                      ? () {
                          ref
                              .read(itemEditProvider.notifier)
                              .addConsumable(
                                item: widget.item,
                                consumables: [selectedItem],
                              );
                          showInfoSnackBar('正在添加...', duration: 1);
                        }
                      : null,
                  child: const Text('添加'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
