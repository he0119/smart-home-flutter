import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:smart_home/blocs/storage/search/search_bloc.dart';
import 'package:smart_home/pages/storage/widgets/storage_item_list.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';

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
        child: SearchScreen(),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showClearButton = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        if (_textController.text.isNotEmpty) _showClearButton = true;
        if (_textController.text.isEmpty) _showClearButton = false;
      });
      context
          .read<StorageSearchBloc>()
          .add(StorageSearchChanged(key: _textController.text));
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration(
              hintText: '搜索',
              suffixIcon: _showClearButton
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? null
                            : Color(0xFF255261),
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
        ),
        body: BlocBuilder<StorageSearchBloc, StorageSearchState>(
          builder: (BuildContext context, StorageSearchState state) {
            if (state is StorageSearchInProgress) {
              return CenterLoadingIndicator();
            }
            if (state is StorageSearchFailure) {
              return Center(child: Text(state.message));
            }
            if (state is StorageSearchSuccess) {
              if (state.items.isEmpty && state.storages.isEmpty) {
                return Center(child: Text('无结果'));
              } else {
                return StorageItemList(
                  items: state.items,
                  storages: state.storages,
                  isHighlight: true,
                  term: state.term,
                );
              }
            }
            return Container();
          },
        ),
      ),
    );
  }
}
