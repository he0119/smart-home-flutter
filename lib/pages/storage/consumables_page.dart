import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/date_format_extension.dart';

class ConsumablesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConsumablesBloc>(
          create: (context) => ConsumablesBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
          )..add(ConsumablesRefreshed()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('耗材管理'),
        ),
        body: BlocBuilder<ConsumablesBloc, ConsumablesState>(
          builder: (context, state) {
            if (state is ConsumablesFailure) {
              return ErrorPage(
                message: state.message,
                onPressed: () {
                  BlocProvider.of<ConsumablesBloc>(context)
                      .add(ConsumablesRefreshed());
                },
              );
            }
            if (state is ConsumablesSuccess) {
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<ConsumablesBloc>(context)
                      .add(ConsumablesRefreshed());
                },
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) =>
                      _buildItem(context, state.items[index]),
                ),
              );
            }
            return LoadingPage();
          },
        ),
      ),
    );
  }
}

Widget _buildItem(BuildContext context, Item item) {
  return Card(
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(item.name),
          onTap: () {
            MyRouterDelegate.of(context).addItemPage(item: item);
          },
        ),
        if (item.consumables != null)
          for (Item consumable in item.consumables)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: ListTile(
                title: Text(consumable.name),
                subtitle: consumable.expiredAt != null
                    ? Text(consumable.expiredAt.differenceFromNowStr())
                    : null,
                onTap: () {
                  MyRouterDelegate.of(context).addItemPage(item: consumable);
                },
              ),
            ),
      ],
    ),
  );
}
