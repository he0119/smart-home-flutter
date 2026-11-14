import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/view/widgets/storage_picker_sheet.dart';
import 'package:smarthome/utils/constants.dart';

const Storage balcony = Storage(id: 'balcony', name: '阳台', parent: homeStorage);
const Storage cabinet = Storage(id: 'cabinet', name: '阳台储物柜', parent: balcony);
const Storage toolbox = Storage(id: 'toolbox', name: '工具箱', parent: balcony);
const Storage box123 = Storage(id: 'box-123', name: '123');
const Storage box1231 = Storage(id: 'box-1231', name: '1231', parent: box123);

const List<Storage> testStorages = <Storage>[
  balcony,
  cabinet,
  toolbox,
  box123,
  box1231,
];

void main() {
  StoragePickerResult? lastResult;

  setUp(() => lastResult = null);

  Widget buildApp({Storage? current}) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: TextButton(
                onPressed: () async {
                  lastResult = await showStoragePicker(
                    context,
                    current: current,
                    storages: testStorages,
                  );
                },
                child: const Text('打开选择器'),
              ),
            );
          },
        ),
      ),
    );
  }

  void useScreen(
    WidgetTester tester, {
    double width = 400,
    double height = 860,
  }) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> openPicker(WidgetTester tester, {Storage? current}) async {
    await tester.pumpWidget(buildApp(current: current));
    await tester.tap(find.text('打开选择器'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows root and first level when opened', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    expect(find.text('选择存放位置'), findsOneWidget);
    expect(find.text('家'), findsOneWidget);
    expect(find.text('阳台'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    // 根节点默认展开，第二层默认收起
    expect(find.text('阳台储物柜'), findsNothing);
  });

  testWidgets('expands and collapses a branch', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('storage-picker-expand-balcony')),
    );
    await tester.pumpAndSettle();
    expect(find.text('阳台储物柜'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('storage-picker-expand-balcony')),
    );
    await tester.pumpAndSettle();
    expect(find.text('阳台储物柜'), findsNothing);
  });

  testWidgets('filters by name and shows the parent path', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    await tester.enterText(find.byType(SearchBar), '阳');
    await tester.pumpAndSettle();

    expect(find.text('共 2 个结果'), findsOneWidget);
    expect(find.text('阳台'), findsOneWidget);
    expect(find.text('阳台储物柜'), findsOneWidget);
    // 副标题只到父级，名字不重复念两遍
    expect(find.text('家 / 阳台'), findsOneWidget);
    expect(find.text('123'), findsNothing);
  });

  testWidgets('keeps expansion after clearing the search', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('storage-picker-expand-balcony')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), '阳');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('清除搜索'));
    await tester.pumpAndSettle();

    // 清空搜索后回到原来的树，之前展开的那一层没有折叠回去
    expect(find.text('阳台储物柜'), findsOneWidget);
    expect(find.text('共 2 个结果'), findsNothing);
  });

  testWidgets('shows empty state when nothing matches', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    await tester.enterText(find.byType(SearchBar), '车库');
    await tester.pumpAndSettle();

    expect(find.text('没有找到「车库」'), findsOneWidget);

    await tester.tap(find.text('清空搜索'));
    await tester.pumpAndSettle();
    expect(find.text('阳台'), findsOneWidget);
  });

  testWidgets('returns the tapped storage and closes', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('storage-picker-row-balcony')),
    );
    await tester.pumpAndSettle();

    expect(lastResult, isNotNull);
    expect(lastResult!.cleared, isFalse);
    expect(lastResult!.storage?.id, 'balcony');
    expect(find.text('选择存放位置'), findsNothing);
  });

  testWidgets('marks the current storage and expands its ancestors', (
    tester,
  ) async {
    useScreen(tester);
    await openPicker(tester, current: cabinet);

    // 没有手动展开，祖先链被自动展开到当前项
    expect(find.text('阳台储物柜'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('当前：家 / 阳台 / 阳台储物柜'), findsOneWidget);
  });

  testWidgets('returns a cleared result from the footer', (tester) async {
    useScreen(tester);
    await openPicker(tester, current: cabinet);

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(lastResult, isNotNull);
    expect(lastResult!.cleared, isTrue);
  });

  testWidgets('uses bottom sheet on phones and dialog on wide screens', (
    tester,
  ) async {
    useScreen(tester);
    await openPicker(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('打开选择器'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('does not overflow when the keyboard opens', (tester) async {
    useScreen(tester);
    await openPicker(tester);

    final before = tester.getSize(find.byType(StoragePicker)).height;
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    final after = tester.getSize(find.byType(StoragePicker)).height;
    expect(tester.takeException(), isNull);
    expect(find.byType(SearchBar), findsOneWidget);
    // 弹层真的被键盘顶上去了，而不是只是没报溢出
    expect(after, lessThan(before));
  });

  testWidgets('exposes the full path to screen readers in search results', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    useScreen(tester);
    await openPicker(tester);

    await tester.enterText(find.byType(SearchBar), '阳');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('家，阳台，阳台储物柜'), findsOneWidget);
    handle.dispose();
  });
}
