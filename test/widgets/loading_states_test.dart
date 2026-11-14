import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/bottom_loader.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';

void main() {
  testWidgets('center loading indicator shows a spinner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CenterLoadingIndicator())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('bottom loader is announced to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BottomLoader())),
    );

    expect(find.bySemanticsLabel('正在加载更多'), findsOneWidget);
    handle.dispose();
  });
}
