import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/widgets/list_rows.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: buildLightTheme(null),
    home: Scaffold(body: child),
  );

  testWidgets('section header uses the muted title style', (tester) async {
    await tester.pumpWidget(wrap(const SectionHeader(title: '最近修改')));

    final text = tester.widget<Text>(find.text('最近修改'));
    final context = tester.element(find.text('最近修改'));
    expect(text.style?.color, Theme.of(context).colorScheme.onSurfaceVariant);
    expect(
      text.style?.fontSize,
      Theme.of(context).textTheme.titleSmall?.fontSize,
    );
  });

  testWidgets('entry row shows a chevron and reacts to taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        EntryRow(
          icon: Icons.storage,
          title: '所有位置',
          supporting: '全部位置和物品',
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.text('全部位置和物品'), findsOneWidget);

    await tester.tap(find.text('所有位置'));
    expect(tapped, isTrue);
  });

  testWidgets('content row shows the supporting line', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ContentRow(
          icon: Icons.inventory_2_outlined,
          title: Text('雨伞'),
          supporting: Text('112 天前'),
        ),
      ),
    );

    expect(find.text('雨伞'), findsOneWidget);
    expect(find.text('112 天前'), findsOneWidget);
  });

  testWidgets('info row puts the label above the value', (tester) async {
    await tester.pumpWidget(wrap(const InfoRow(label: '数量', value: Text('3'))));

    final labelRect = tester.getRect(find.text('数量'));
    final valueRect = tester.getRect(find.text('3'));
    expect(valueRect.top, greaterThan(labelRect.bottom - 1));
  });
}
