// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/main.dart';

void main() {
  testWidgets('home page test', (WidgetTester tester) async {
    var configuredApp = AppConfig(
      appName: '智慧家庭 DEV',
      flavorName: 'development',
      apiUrl: 'http://192.168.31.12:8000/graphql',
      child: MyApp(),
    );
    await tester.pumpWidget(configuredApp);
    expect(find.text('注销'), findsNothing);
  });
}
