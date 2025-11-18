import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/providers/search_provider.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/center_message.dart';
import 'package:smarthome/widgets/chips.dart';
import 'package:smarthome/widgets/home_page.dart';

class SearchPage extends Page {
  // 按理来说每个搜索界面都不一样，所以每个界面的 key 都应不同
  SearchPage() : super(key: UniqueKey(), name: '/search');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const SearchScreen(),
    );
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
      ref
          .read(searchProvider.notifier)
          .search(
            _textController.text,
            isDeleted: _isDeleted,
            missingStorage: _missingStorage,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: MySliverScaffold(
        appBarSize: AppBarSize.normal,
        title: TextField(
          decoration: InputDecoration(
            hintText: '搜索',
            suffixIcon: _showClearButton
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _textController.text = '';
                    },
                  )
                : null,
            border: InputBorder.none,
          ),
          autofocus: true,
          controller: _textController,
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
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}
