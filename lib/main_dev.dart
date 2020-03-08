import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/simple_bloc_delegate.dart';

import 'main.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  var configuredApp = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'development',
    apiUrl: 'http://118.24.9.142:8000/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
