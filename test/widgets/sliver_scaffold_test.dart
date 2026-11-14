import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/widgets/home_page.dart';

void main() {
  Widget buildSubject({double contentMaxWidth = 600, Widget? rail}) {
    return MaterialApp(
      theme: buildLightTheme(null),
      home: MySliverScaffold(
        title: const Text('物品'),
        contentMaxWidth: contentMaxWidth,
        navigationRail: rail,
        slivers: const <Widget>[
          SliverToBoxAdapter(child: SizedBox(height: 1200)),
        ],
      ),
    );
  }

  testWidgets('wide screens limit the content width', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildSubject());

    expect(tester.getSize(find.byType(CustomScrollView)).width, 600);
  });

  testWidgets('narrow screens keep the full width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildSubject(contentMaxWidth: 920));

    expect(tester.getSize(find.byType(CustomScrollView)).width, 390);
  });

  testWidgets('navigation rail is laid out next to the content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildSubject(
        rail: NavigationRail(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.storage),
              label: Text('物品'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.chat),
              label: Text('留言板'),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);

    final railSize = tester.getSize(find.byType(NavigationRail));
    final contentSize = tester.getSize(find.byType(CustomScrollView));
    expect(railSize.width + contentSize.width, lessThanOrEqualTo(1200));
  });
}
