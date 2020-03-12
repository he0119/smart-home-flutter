import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/search_bloc.dart';
import 'package:smart_home/widgets/search_form.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物品搜索'),
      ),
      body: BlocProvider(
        create: (context) => StorageSearchBloc(),
        child: SearchForm(),
      ),
    );
  }
}
