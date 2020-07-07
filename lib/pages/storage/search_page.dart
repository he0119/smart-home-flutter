import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/search/search_bloc.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/pages/storage/widgets/search_form.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物品搜索'),
      ),
      body: BlocProvider(
        create: (context) => StorageSearchBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        ),
        child: SearchForm(),
      ),
    );
  }
}
