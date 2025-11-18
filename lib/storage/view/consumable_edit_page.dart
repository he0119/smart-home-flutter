import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/item_edit_provider.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/dropdown_search.dart';
import 'package:smarthome/widgets/home_page.dart';
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
      title: const Text('耗材编辑'),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            if (current.consumables!.isEmpty)
              const ListTile(title: Text('无耗材')),
            for (Item consumable in current.consumables!)
              ListTile(
                title: Text(consumable.name),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref
                        .read(itemEditProvider.notifier)
                        .deleteConsumable(
                          item: widget.item,
                          consumables: [consumable],
                        );
                    showInfoSnackBar('正在删除...', duration: 1);
                  },
                ),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: MyDropdownSearch(
                label: '耗材',
                items: (text, loadProps) async {
                  final storageRepository = ref.read(storageRepositoryProvider);
                  final items = await storageRepository.items(
                    key: text,
                    cache: false,
                  );
                  return items;
                },
                showClearButton: true,
                onChanged: (Item? value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
          ],
        ),
      ),
    );
  }
}
