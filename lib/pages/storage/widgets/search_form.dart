import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/search/search_bloc.dart';
import 'package:smart_home/pages/storage/widgets/storage_item_list.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  StorageSearchBloc _storageSearchBloc;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: UniqueKey(),
      autofocus: true,
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _storageSearchBloc.add(
          StorageSearchChanged(key: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Colors.blue,
        ),
        suffixIcon: GestureDetector(
          child: Icon(
            Icons.clear,
            color: Colors.blue,
          ),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: '请输入',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _storageSearchBloc = BlocProvider.of<StorageSearchBloc>(context);
  }

  void _onClearTapped() {
    _textController.text = '';
    _storageSearchBloc.add(StorageSearchChanged(key: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageSearchBloc, StorageSearchState>(
      builder: (BuildContext context, StorageSearchState state) {
        if (state is StorageSearchInProgress) {
          return CircularProgressIndicator();
        }
        if (state is StorageSearchFailure) {
          return Text(state.message);
        }
        if (state is StorageSearchSuccess) {
          return state.items.isEmpty && state.storages.isEmpty
              ? Text('无结果')
              : Expanded(
                  child: StorageItemList(
                    items: state.items,
                    storages: state.storages,
                    isHighlight: true,
                    term: state.term,
                    onPopDetailPage: () =>
                        BlocProvider.of<StorageSearchBloc>(context)
                            .add(StorageSearchChanged(key: state.term)),
                  ),
                );
        }
        return Text('');
      },
    );
  }
}
