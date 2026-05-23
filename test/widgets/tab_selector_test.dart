import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/tab_selector.dart';

void main() {
  testWidgets('TabSelector uses bottom navigation on compact layouts', (
    tester,
  ) async {
    AppTab? selectedTab;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: TabSelector(
            activeTab: AppTab.storage,
            onTabSelected: (tab) => selectedTab = tab,
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await tester.tap(find.text('博客'));
    await tester.pump();

    expect(selectedTab, AppTab.blog);
  });

  testWidgets('RailTabSelector uses navigation rail on wide layouts', (
    tester,
  ) async {
    AppTab? selectedTab;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RailTabSelector(
            activeTab: AppTab.storage,
            onTabSelected: (tab) => selectedTab = tab,
          ),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.chat));
    await tester.pump();

    expect(selectedTab, AppTab.board);
  });
}
