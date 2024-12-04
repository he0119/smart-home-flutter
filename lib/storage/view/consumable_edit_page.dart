import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/dropdown_search.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class ConsumableEditPage extends StatefulWidget {
  final Item item;

  const ConsumableEditPage({
    super.key,
    required this.item,
  });

  @override
  State<ConsumableEditPage> createState() => _ConsumableEditPageState();
}

class _ConsumableEditPageState extends State<ConsumableEditPage> {
  Item? selectedItem;
  late Item current;

  @override
  void initState() {
    super.initState();
    current = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      title: const Text('耗材编辑'),
      sliver: BlocConsumer<ItemEditBloc, ItemEditState>(
        listener: (context, state) {
          if (state is ConsumableAddSuccess) {
            showInfoSnackBar('耗材添加成功');
            setState(() {
              current = state.item;
            });
          }
          if (state is ConsumableDeleteSuccess) {
            showInfoSnackBar('耗材删除成功');
            setState(() {
              current = state.item;
            });
          }
          if (state is ItemEditFailure) {
            showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) => SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              if (current.consumables!.isEmpty)
                const ListTile(
                  title: Text('无耗材'),
                ),
              for (Item consumable in current.consumables!)
                ListTile(
                  title: Text(consumable.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      BlocProvider.of<ItemEditBloc>(context).add(
                        ConsumableDeleted(
                          item: widget.item,
                          consumables: [consumable],
                        ),
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
                    final items =
                        await RepositoryProvider.of<StorageRepository>(context)
                            .items(key: text, cache: false);
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
                      (state is! ItemEditInProgress && selectedItem != null)
                          ? () {
                              BlocProvider.of<ItemEditBloc>(context).add(
                                ConsumableAdded(
                                  item: widget.item,
                                  consumables: [selectedItem],
                                ),
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
      ),
    );
  }
}
