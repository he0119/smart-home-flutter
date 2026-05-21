import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:smarthome/widgets/date_time_picker_formfield.dart';

void main() {
  Widget buildSubject({
    DateTime? initialValue,
    ValueChanged<DateTime?>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DateTimePickerFormField(
          decoration: const InputDecoration(labelText: '有效期至'),
          format: DateFormat('yyyy-MM-dd HH:mm'),
          initialValue: initialValue,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('shows formatted initial value', (tester) async {
    await tester.pumpWidget(
      buildSubject(initialValue: DateTime(2026, 5, 21, 12, 30)),
    );

    expect(find.text('有效期至'), findsOneWidget);
    expect(find.text('2026-05-21 12:30'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(find.byIcon(Icons.event), findsNothing);
  });

  testWidgets('shows event icon when value is empty', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('有效期至'), findsOneWidget);
    expect(find.byIcon(Icons.event), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('clears selected value', (tester) async {
    DateTime? changedValue = DateTime(2026, 5, 21, 12, 30);
    await tester.pumpWidget(
      buildSubject(
        initialValue: changedValue,
        onChanged: (value) => changedValue = value,
      ),
    );

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(changedValue, isNull);
    expect(find.text('2026-05-21 12:30'), findsNothing);
    expect(find.byIcon(Icons.event), findsOneWidget);
  });

  testWidgets('opens date picker when tapped', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
