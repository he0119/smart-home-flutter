import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("搜索")),
        body: SearchForm(),
      ),
    );
  }
}

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
  StorageBloc _storageBloc;

  @override
  void initState() {
    super.initState();
    _storageBloc = BlocProvider.of<StorageBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _storageBloc.add(
          StorageSearchChanged(text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: '请输入',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _storageBloc.add(StorageSearchChanged(''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      bloc: BlocProvider.of<StorageBloc>(context),
      builder: (BuildContext context, StorageState state) {
        if (state is StorageLoading) {
          return CircularProgressIndicator();
        }
        if (state is StorageError) {
          return Text(state.message);
        }
        if (state is StorageSearchResults) {
          return state.items.isEmpty && state.storages.isEmpty
              ? Text('无结果')
              : Expanded(
                  child: _SearchResults(
                  items: state.items,
                  storages: state.storages,
                ));
        }
        return Text('');
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;

  const _SearchResults({Key key, this.items, this.storages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(items)..addAll(storages);
    return ListView.builder(
      itemCount: merged.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: merged[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final dynamic item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () async {},
      );
    } else {
      return ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () async {},
      );
    }
  }
}
