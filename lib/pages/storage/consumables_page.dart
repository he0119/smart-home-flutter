import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';
import 'package:smart_home/widgets/infinite_list.dart';

class ConsumablesPage extends Page {
  ConsumablesPage() : super(key: UniqueKey(), name: '/consumables');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlocProvider<ConsumablesBloc>(
        create: (context) => ConsumablesBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        )..add(ConsumablesFetched()),
        child: ConsumablesScreen(),
      ),
    );
  }
}

class ConsumablesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('耗材管理'),
      ),
      body: BlocBuilder<ConsumablesBloc, ConsumablesState>(
        builder: (context, state) {
          if (state is ConsumablesFailure) {
            return ErrorMessageButton(
              message: state.message,
              onPressed: () {
                BlocProvider.of<ConsumablesBloc>(context)
                    .add(ConsumablesFetched(cache: false));
              },
            );
          }
          if (state is ConsumablesSuccess) {
            return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<ConsumablesBloc>(context)
                      .add(ConsumablesFetched(cache: false));
                },
                child: InfiniteList(
                  itemBuilder: _buildItem,
                  items: state.items,
                  hasReachedMax: state.hasReachedMax,
                  onFetch: () =>
                      context.read<ConsumablesBloc>().add(ConsumablesFetched()),
                ));
          }
          return CenterLoadingIndicator();
        },
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
                trailing: Text(consumable.number.toString()),
              ),
            ),
      ],
    ),
  );
}
