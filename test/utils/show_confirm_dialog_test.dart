import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';

void main() {
  Widget buildSubject({
    required void Function(bool) onResult,
    bool destructive = false,
  }) {
    return MaterialApp(
      theme: buildLightTheme(null),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: TextButton(
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: '删除这个位置',
                    message: '删除后无法恢复',
                    confirmLabel: '删除',
                    destructive: destructive,
                  );
                  onResult(confirmed);
                },
                child: const Text('打开'),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('confirming returns true and shows verb labels', (tester) async {
    bool? result;
    await tester.pumpWidget(buildSubject(onResult: (value) => result = value));

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('删除这个位置'), findsOneWidget);
    expect(find.text('删除后无法恢复'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('cancelling returns false', (tester) async {
    bool? result;
    await tester.pumpWidget(buildSubject(onResult: (value) => result = value));

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('destructive confirm uses the error color', (tester) async {
    await tester.pumpWidget(buildSubject(onResult: (_) {}, destructive: true));
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final context = tester.element(find.byType(AlertDialog));
    final colors = Theme.of(context).colorScheme;

    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      colors.error,
    );
    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      colors.onError,
    );
  });

  testWidgets('non destructive confirm keeps the default color', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(onResult: (_) {}));
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.style?.backgroundColor, isNull);
  });
}
