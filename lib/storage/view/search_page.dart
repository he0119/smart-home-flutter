import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/providers/search_provider.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/chips.dart';
import 'package:smarthome/widgets/state_views.dart';
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
  bool _isDeleted = false;
  bool _missingStorage = false;

  final _textController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {});
      doSearch();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  /// 立即搜索，用于切筛选条件
  void _searchNow() {
    _debounceTimer?.cancel();
    ref
        .read(searchProvider.notifier)
        .search(
          _textController.text,
          isDeleted: _isDeleted,
          missingStorage: _missingStorage,
        );
  }

  /// 输入时防抖
  void doSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _searchNow);
  }

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      appBarSize: AppBarSize.normal,
      title: SearchBar(
        controller: _textController,
        hintText: '搜索物品和位置',
        leading: const Icon(Icons.search, size: 20),
        trailing: <Widget>[
          if (_textController.text.isNotEmpty)
            IconButton(
              tooltip: '清除',
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _textController.text = '';
              },
            ),
        ],
        elevation: const WidgetStatePropertyAll<double>(0),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        constraints: const BoxConstraints(minHeight: 48),
        textInputAction: TextInputAction.search,
        autoFocus: true,
        // 点页面其它区域时收起键盘
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Wrap(
              children: <Widget>[
                MyFilterChip(
                  label: const Text('已删除'),
                  selected: _isDeleted,
                  onSelected: (value) {
                    setState(() {
                      _isDeleted = value;
                    });
                    _searchNow();
                  },
                ),
                MyFilterChip(
                  label: const Text('无位置'),
                  selected: _missingStorage,
                  onSelected: (value) {
                    setState(() {
                      _missingStorage = value;
                    });
                    _searchNow();
                  },
                ),
              ],
            ),
          ),
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final state = ref.watch(searchProvider);
            if (state.status == SearchStatus.loading) {
              return const SliverCenterLoadingIndicator();
            }
            if (state.status == SearchStatus.failure) {
              return SliverErrorState(message: state.errorMessage);
            }
            if (state.status == SearchStatus.success) {
              if (state.items.isEmpty && state.storages.isEmpty) {
                return const SliverEmptyState(
                  icon: Icons.search_off,
                  title: '没有找到相关内容',
                  message: '换个关键字试试，或者关掉筛选条件',
                );
              } else {
                return StorageItemList(
                  items: state.items,
                  storages: state.storages,
                  isHighlight: true,
                  term: state.term,
                );
              }
            }
            return const SliverEmptyState(
              icon: Icons.search,
              title: '搜索物品和位置',
              message: '输入名称或备注里的关键字',
            );
          },
        ),
      ],
    );
  }
}
