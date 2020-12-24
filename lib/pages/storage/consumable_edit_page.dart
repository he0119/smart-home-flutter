import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/widgets/dropdown_search.dart';
import 'package:smart_home/widgets/rounded_raised_button.dart';
import 'package:smart_home/utils/show_snack_bar.dart';

class ConsumableEditPage extends StatefulWidget {
  final Item item;

  const ConsumableEditPage({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  _ConsumableEditPageState createState() => _ConsumableEditPageState();
}

class _ConsumableEditPageState extends State<ConsumableEditPage> {
  Item selectedItem;
  Item current;

  @override
  void initState() {
    super.initState();
    current = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('耗材编辑'),
      ),
      body: BlocConsumer<ItemEditBloc, ItemEditState>(
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
        builder: (context, state) => SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (current.consumables.isEmpty)
                ListTile(
                  title: Text('无耗材'),
                ),
              for (Item consumable in current.consumables)
                ListTile(
                  title: Text(consumable.name),
                  trailing: IconButton(
                    icon: Icon(Icons.clear),
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
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: MyDropdownSearch(
                  label: '耗材',
                  onFind: (text) {
                    final items =
                        RepositoryProvider.of<StorageRepository>(context)
                            .items(key: text, cache: false);
                    return items;
                  },
                  showClearButton: true,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                ),
              ),
              RoundedRaisedButton(
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
                child: Text('添加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
