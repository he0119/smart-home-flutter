import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/storage/blocs/storage_bloc.dart';

import 'services/shared_preferences_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  initMethod(context) async {
    await sharedPreferenceService.getSharedPreferencesInstance();
    String _token = await sharedPreferenceService.token;
    if (_token == null || _token == "") {
      print('未登录');
    } else
      print('已登录');
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initMethod(context));
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (context) => StorageBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('智慧家庭'),
      ),
      body: BlocBuilder<StorageBloc, StorageState>(
        builder: (context, state) {
          if (state is Initial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('无数据'),
                ],
              ),
            );
          }
          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errors.toString()),
                ],
              ),
            );
          }
          if (state is SearchResults) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (BuildContext context, int index) =>
                  ListTile(title: Text(state.items[index].name)),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '按下按钮获取数据',
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<StorageBloc>(context).add(StartSearch('test'));
        },
        tooltip: 'Start',
        child: Icon(Icons.timer),
      ),
    );
  }
}
