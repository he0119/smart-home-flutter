import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/widgets/settings/settings_section.dart';
import 'package:smarthome/widgets/settings/settings_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: buildLightTheme(null),
    home: Scaffold(body: child),
  );

  testWidgets('tappable settings tile shows a chevron', (tester) async {
    await tester.pumpWidget(wrap(SettingsTile(title: '主题', onPressed: (_) {})));

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('non tappable settings tile has no chevron', (tester) async {
    await tester.pumpWidget(wrap(const SettingsTile(title: '版本')));

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('section title uses the muted color instead of secondary', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SettingsSection(
          title: '通用',
          tiles: <Widget>[SettingsTile(title: '主题', onPressed: (_) {})],
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('通用'));
    final colors = Theme.of(tester.element(find.text('通用'))).colorScheme;

    expect(title.style?.color, colors.onSurfaceVariant);
    expect(title.style?.fontWeight, isNot(FontWeight.bold));
  });
}
