import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/storage/view/item_datail_page.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class ConsumablesPage extends Page {
  ConsumablesPage() : super(key: UniqueKey(), name: '/consumables');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlocProvider<ConsumablesBloc>(
        create: (context) => ConsumablesBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        )..add(const ConsumablesFetched()),
        child: const ConsumablesScreen(),
      ),
    );
  }
}

class ConsumablesScreen extends StatelessWidget {
  const ConsumablesScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsumablesBloc, ConsumablesState>(
      builder: (context, state) {
        return MySliverScaffold(
          title: const Text('耗材管理'),
          slivers: [
            if (state is ConsumablesFailure)
              SliverErrorMessageButton(
                message: state.message,
                onPressed: () {
                  BlocProvider.of<ConsumablesBloc>(context)
                      .add(const ConsumablesFetched(cache: false));
                },
              ),
            if (state is ConsumablesSuccess)
              SliverInfiniteList(
                itemBuilder: _buildItem,
                items: state.items,
                hasReachedMax: state.hasReachedMax,
                onFetch: () => context
                    .read<ConsumablesBloc>()
                    .add(const ConsumablesFetched()),
              ),
            if (state is ConsumablesInProgress)
              const SliverCenterLoadingIndicator(),
          ],
          onRefresh: () async {
            BlocProvider.of<ConsumablesBloc>(context)
                .add(const ConsumablesFetched(cache: false));
          },
        );
      },
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
            MyRouterDelegate.of(context).push(ItemDetailPage(itemId: item.id));
          },
        ),
        if (item.consumables != null)
          for (Item consumable in item.consumables!)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: ListTile(
                title: Text(consumable.name),
                subtitle: consumable.expiredAt != null
                    ? Text(consumable.expiredAt!.differenceFromNowStr())
                    : null,
                onTap: () {
                  MyRouterDelegate.of(context).push(
                    ItemDetailPage(itemId: consumable.id),
                  );
                },
                trailing: Text(consumable.number.toString()),
              ),
            ),
      ],
    ),
  );
}
