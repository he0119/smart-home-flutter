import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/list_rows.dart';

void main() {
  testWidgets('separator is only drawn between rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverInfiniteList<int>(
                items: const <int>[1, 2, 3],
                separatorBuilder: (context, item) => const ContentDivider(),
                itemBuilder: (context, item) =>
                    SizedBox(height: 72, child: Text('行 $item')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ContentDivider), findsNWidgets(2));
  });

  testWidgets('no separator when the list is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverInfiniteList<int>(
                items: const <int>[],
                separatorBuilder: (context, item) => const ContentDivider(),
                itemBuilder: (context, item) => const SizedBox(height: 72),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ContentDivider), findsNothing);
  });
}
