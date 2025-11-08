import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
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
      builder: (context) => BlocProvider(
        create: (context) => StorageSearchBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        ),
        child: const SearchScreen(),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showClearButton = false;
  bool _isDeleted = false;
  bool _missingStorage = false;

  final _textController = TextEditingController();

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
    _textController.dispose();
    super.dispose();
  }

  void doSearch() {
    context.read<StorageSearchBloc>().add(
      StorageSearchChanged(
        key: _textController.text,
        isDeleted: _isDeleted,
        missingStorage: _missingStorage,
      ),
    );
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
        sliver: BlocBuilder<StorageSearchBloc, StorageSearchState>(
          builder: (BuildContext context, StorageSearchState state) {
            if (state is StorageSearchInProgress) {
              return const SliverCenterLoadingIndicator();
            }
            if (state is StorageSearchFailure) {
              return SliverCenterMessage(message: state.message);
            }
            if (state is StorageSearchSuccess) {
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
