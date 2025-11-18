import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/consumables_provider.dart';

import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class ConsumablesPage extends StatelessWidget {
  const ConsumablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConsumablesScreen();
  }
}

class ConsumablesScreen extends ConsumerWidget {
  const ConsumablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consumablesProvider);
    return MySliverScaffold(
      title: const Text('耗材管理'),
      slivers: [
        if (state.status == ConsumablesStatus.failure)
          SliverErrorMessageButton(
            message: state.errorMessage,
            onPressed: () {
              ref.read(consumablesProvider.notifier).fetch(cache: false);
            },
          ),
        if (state.status == ConsumablesStatus.success)
          SliverInfiniteList(
            itemBuilder: _buildItem,
            items: state.items,
            hasReachedMax: state.hasReachedMax,
            onFetch: () => ref.read(consumablesProvider.notifier).fetch(),
          ),
        if (state.status == ConsumablesStatus.loading)
          const SliverCenterLoadingIndicator(),
      ],
      onRefresh: () async {
        ref.read(consumablesProvider.notifier).fetch(cache: false);
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
            context.goItemDetail(item.id);
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
                  context.goItemDetail(consumable.id);
                },
                trailing: Text(consumable.number.toString()),
              ),
            ),
      ],
    ),
  );
}
