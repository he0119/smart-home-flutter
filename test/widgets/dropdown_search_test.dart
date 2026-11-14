import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome/widgets/dropdown_search.dart';

void main() {
  // 用字符串当候选项，Item.toString() 这类展示逻辑不在本组件职责内
  Future<List<String>> fakeLoader(String text) async {
    const all = <String>['苹果', '香蕉', '橙子'];
    if (text.isEmpty) {
      return all;
    }
    return all.where((element) => element.contains(text)).toList();
  }

  Widget buildSubject({
    String? selectedItem,
    ValueChanged<String?>? onSelected,
    bool showClearButton = false,
    DropdownItemsLoader<String>? items,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MyDropdownSearch<String>(
          label: '耗材',
          items: items ?? fakeLoader,
          onSelected: onSelected,
          selectedItem: selectedItem,
          showClearButton: showClearButton,
        ),
      ),
    );
  }

  testWidgets('shows label and selected item', (tester) async {
    await tester.pumpWidget(buildSubject(selectedItem: '苹果'));

    expect(find.text('耗材'), findsOneWidget);
    expect(find.text('苹果'), findsOneWidget);
  });

  testWidgets('clear button is hidden without selection', (tester) async {
    await tester.pumpWidget(buildSubject(showClearButton: true));

    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('clear button clears the selection', (tester) async {
    String? changedValue = '苹果';
    await tester.pumpWidget(
      buildSubject(
        selectedItem: '苹果',
        showClearButton: true,
        onSelected: (value) => changedValue = value,
      ),
    );

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(changedValue, isNull);
    expect(find.text('苹果'), findsNothing);
  });

  testWidgets('opens dialog and loads all items', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('苹果'), findsOneWidget);
    expect(find.text('香蕉'), findsOneWidget);
    expect(find.text('橙子'), findsOneWidget);
  });

  testWidgets('selecting an item returns it to the parent', (tester) async {
    String? changedValue;
    await tester.pumpWidget(
      buildSubject(onSelected: (value) => changedValue = value),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('香蕉'));
    await tester.pumpAndSettle();

    expect(changedValue, '香蕉');
    // 弹窗关闭，并且选中项显示在输入框里
    expect(find.text('搜索'), findsNothing);
    expect(find.text('香蕉'), findsOneWidget);
  });

  testWidgets('searching sends the keyword to the loader', (tester) async {
    final keywords = <String>[];
    await tester.pumpWidget(
      buildSubject(
        items: (text) async {
          keywords.add(text);
          return fakeLoader(text);
        },
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '香');
    // 输入经过 300ms 防抖后才发起请求
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(keywords, <String>['', '香']);
    expect(find.text('香蕉'), findsOneWidget);
    expect(find.text('苹果'), findsNothing);
  });

  testWidgets('shows empty message when nothing matches', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '西瓜');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('无结果'), findsOneWidget);
  });

  testWidgets('shows error message when loader fails', (tester) async {
    await tester.pumpWidget(
      buildSubject(items: (text) async => throw Exception('网络错误')),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('加载失败'), findsOneWidget);
  });
}
