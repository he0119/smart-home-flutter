// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/main.dart';

void main() {
  testWidgets('home page test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) =>
                AuthenticationBloc()..add(AppStarted()),
          ),
          BlocProvider<StorageSearchBloc>(
            create: (BuildContext context) => StorageSearchBloc(),
          ),
          BlocProvider<StorageBloc>(
            create: (BuildContext context) => StorageBloc(),
          ),
        ],
        child: MyApp(),
      ),
    );

    // Verify that our counter starts at 0.
    // expect(find.text('登录'), findsWidgets);
    expect(find.text('注销'), findsNothing);
  });
}
