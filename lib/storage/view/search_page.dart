import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/providers/search_provider.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/center_message.dart';
import 'package:smarthome/widgets/chips.dart';
import 'package:smarthome/widgets/home_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchScreen();
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool _showClearButton = false;
  bool _isDeleted = false;
  bool _missingStorage = false;

  final _textController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(searchProvider.notifier).loadHistory());
    _textController.addListener(() {
      setState(() {
        if (_textController.text.isNotEmpty) _showClearButton = true;
        if (_textController.text.isEmpty) _showClearButton = false;
      });
      doSearch();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void doSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _search(_textController.text);
    });
  }

  void _search(String key) {
    ref
        .read(searchProvider.notifier)
        .search(key, isDeleted: _isDeleted, missingStorage: _missingStorage);
  }

  void _searchHistory(String key) {
    _debounceTimer?.cancel();
    _textController.text = key;
    _textController.selection = TextSelection.collapsed(offset: key.length);
    _debounceTimer?.cancel();
    _search(key);
  }

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      appBarSize: AppBarSize.normal,
      title: SearchBar(
        hintText: '搜索',
        leading: const Icon(Icons.search),
        trailing: [
          if (_showClearButton)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: '清除',
              onPressed: _textController.clear,
            ),
        ],
        autoFocus: true,
        controller: _textController,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      appbarBottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          children: [
            MyChoiceChip(
              label: const Text('已删除'),
              selected: _isDeleted,
              onSelected: (value) {
                setState(() {
                  _isDeleted = value;
                  doSearch();
                });
              },
            ),
            MyChoiceChip(
              label: const Text('无位置'),
              selected: _missingStorage,
              onSelected: (value) {
                setState(() {
                  _missingStorage = value;
                  doSearch();
                });
              },
            ),
          ],
        ),
      ),
      sliver: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final state = ref.watch(searchProvider);
          if (state.status == SearchStatus.loading) {
            return const SliverCenterLoadingIndicator();
          }
          if (state.status == SearchStatus.failure) {
            return SliverCenterMessage(message: state.errorMessage);
          }
          if (state.status == SearchStatus.success) {
            if (state.items.isEmpty && state.storages.isEmpty) {
              return const SliverCenterMessage(message: '无结果');
            } else {
              return StorageItemList(
                items: state.items,
                storages: state.storages,
                isHighlight: true,
                term: state.term,
              );
            }
          }
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _SearchHistoryList(
              history: state.history,
              onTap: _searchHistory,
              onRemove: (key) =>
                  ref.read(searchProvider.notifier).removeHistory(key),
              onClear: () => ref.read(searchProvider.notifier).clearHistory(),
            ),
          );
        },
      ),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  const _SearchHistoryList({
    required this.history,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text('搜索历史', style: Theme.of(context).textTheme.titleMedium),
          trailing: TextButton(onPressed: onClear, child: const Text('清空')),
        ),
        for (final key in history)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(key),
            onTap: () => onTap(key),
            trailing: IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.close),
              onPressed: () => onRemove(key),
            ),
          ),
      ],
    );
  }
}
