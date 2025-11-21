import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/providers/board_home_provider.dart';
import 'package:smarthome/board/view/topic_edit_page.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class BoardHomePage extends ConsumerWidget {
  const BoardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(boardHomeProvider);
    return AdaptiveHomePage(
      floatingActionButton: FloatingActionButton(
        tooltip: '添加话题',
        onPressed: () async {
          final r = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TopicEditPage(isEditing: false),
            ),
          );
          if (r == true) {
            ref.read(boardHomeProvider.notifier).fetch(cache: false);
          }
        },
        child: const Icon(Icons.create),
      ),
      slivers: [
        if (state.status == BoardHomeStatus.failure)
          SliverErrorMessageButton(
            onPressed: () {
              ref.read(boardHomeProvider.notifier).fetch(cache: false);
            },
            message: state.errorMessage,
          ),
        if (state.status == BoardHomeStatus.loading)
          const SliverCenterLoadingIndicator(),
        if (state.status == BoardHomeStatus.success)
          SliverInfiniteList<Topic>(
            items: state.topics,
            hasReachedMax: state.hasReachedMax,
            itemBuilder: (context, item) => TopicItem(topic: item),
            onFetch: () {
              ref.read(boardHomeProvider.notifier).fetch();
            },
          ),
      ],
      onRefresh: () async {
        ref.read(boardHomeProvider.notifier).fetch(cache: false);
      },
    );
  }
}
