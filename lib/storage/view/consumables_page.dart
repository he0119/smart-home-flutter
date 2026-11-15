import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/consumables_provider.dart';

import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/state_views.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/list_rows.dart';

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
          SliverErrorState(
            message: state.errorMessage,
            onRetry: () {
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
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final consumables = item.consumables ?? const <Item>[];

  return Column(
    crossAxisAlignment: .stretch,
    children: <Widget>[
      SectionHeader(
        title: item.name,
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        action: TextButton(
          onPressed: () {
            context.goItemDetail(item.id);
          },
          child: const Text('查看'),
        ),
      ),
      if (consumables.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '没有耗材',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        )
      else
        for (var i = 0; i < consumables.length; i++) ...<Widget>[
          ContentRow(
            icon: Icons.inventory_2_outlined,
            title: Text(consumables[i].name),
            supporting: consumables[i].expiredAt == null
                ? null
                : Text(consumables[i].expiredAt!.differenceFromNowStr()),
            trailing: Text(
              '× ${consumables[i].number}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              context.goItemDetail(consumables[i].id);
            },
          ),
          if (i < consumables.length - 1) const ContentDivider(),
        ],
    ],
  );
}
