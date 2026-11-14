import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';

void main() {
  late ThemeData light;
  late ThemeData dark;

  Future<void> pumpThemes(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(null),
        darkTheme: buildDarkTheme(null),
        home: Builder(
          builder: (BuildContext context) {
            light = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    dark = buildDarkTheme(null);
  }

  testWidgets('input fields are filled with a 12 radius', (tester) async {
    await pumpThemes(tester);

    expect(light.inputDecorationTheme.filled, isTrue);
    expect(light.inputDecorationTheme.fillColor, isNotNull);
    final border = light.inputDecorationTheme.border! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(12));
    expect(border.borderSide.width, 0);
  });

  testWidgets('chips use the 8 radius instead of a per-widget override', (
    tester,
  ) async {
    await pumpThemes(tester);

    final shape = light.chipTheme.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('buttons share the same height and radius', (tester) async {
    await pumpThemes(tester);

    for (final style in <ButtonStyle>[
      light.filledButtonTheme.style!,
      light.elevatedButtonTheme.style!,
      light.outlinedButtonTheme.style!,
    ]) {
      expect(style.minimumSize!.resolve(<WidgetState>{}), const Size(64, 48));
      final shape = style.shape!.resolve(<WidgetState>{})!;
      expect(
        (shape as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(12),
      );
    }
  });

  testWidgets('light and dark share the same component themes', (tester) async {
    await pumpThemes(tester);

    expect(dark.brightness, Brightness.dark);
    expect(dark.inputDecorationTheme.filled, light.inputDecorationTheme.filled);
    expect(dark.chipTheme.shape, light.chipTheme.shape);
    expect(
      dark.filledButtonTheme.style!.minimumSize,
      light.filledButtonTheme.style!.minimumSize,
    );
    // 暗色的填充色要跟着暗色配色走，不能沿用亮色
    expect(
      dark.inputDecorationTheme.fillColor,
      isNot(light.inputDecorationTheme.fillColor),
    );
  });
}
