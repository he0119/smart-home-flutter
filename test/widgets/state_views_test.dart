import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/state_views.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('empty state shows icon, title, message and action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.search_off,
          title: '没有找到相关物品',
          message: '换个关键字试试',
          action: TextButton(
            onPressed: () => tapped = true,
            child: const Text('清空搜索'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('没有找到相关物品'), findsOneWidget);
    expect(find.text('换个关键字试试'), findsOneWidget);

    await tester.tap(find.text('清空搜索'));
    expect(tapped, isTrue);
  });

  testWidgets('error state retries through the callback', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      wrap(ErrorState(message: '网络请求失败', onRetry: () => retried++)),
    );

    expect(find.text('加载失败'), findsOneWidget);
    expect(find.text('网络请求失败'), findsOneWidget);

    await tester.tap(find.text('重试'));
    expect(retried, 1);
  });

  testWidgets('sliver variants fill the remaining space', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              const SliverAppBar(title: Text('位置')),
              SliverEmptyState(title: '还没有物品'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('还没有物品'), findsOneWidget);
    expect(find.byType(SliverEmptyState), findsOneWidget);
  });

  testWidgets('loading state can carry a message', (tester) async {
    await tester.pumpWidget(wrap(const LoadingState(message: '正在加载位置')));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('正在加载位置'), findsOneWidget);
  });
}
