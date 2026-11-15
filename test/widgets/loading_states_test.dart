import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/bottom_loader.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/state_views.dart';

void main() {
  testWidgets('center loading indicator shows a spinner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CenterLoadingIndicator())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('center loading indicator announces a loading label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CenterLoadingIndicator())),
    );

    expect(
      tester.getSemantics(find.byType(CircularProgressIndicator)),
      isSemantics(label: '正在加载'),
    );
    handle.dispose();
  });

  testWidgets('loading state with message keeps the generic spinner label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingState(message: '正在加载物品')),
      ),
    );

    // 转圈的语义值留给完成百分比，不塞 message，避免和下面那行文字重复播报。
    expect(
      tester.getSemantics(find.byType(CircularProgressIndicator)),
      isSemantics(label: '正在加载'),
    );
    expect(find.bySemanticsLabel('正在加载物品'), findsOneWidget);
    handle.dispose();
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
