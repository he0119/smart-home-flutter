import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smarthome/widgets/bottom_loader.dart';
import 'package:smarthome/widgets/infinite_list.dart';

abstract class OnFetch {
  void call();
}

class MockOnFetch extends Mock implements OnFetch {}

void main() {
  testWidgets(
    'InfiniteList should not show loading indicator when reached max',
    (tester) async {
      final List<int> items = List<int>.generate(20, (int i) => i);
      const double itemHeight = 300.0;
      const double viewportHeight = 500.0;
      const double scrollPosition = 19 * itemHeight;
      final ScrollController controller = ScrollController();
      final mockOnFetch = MockOnFetch();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: viewportHeight,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverInfiniteList<int>(
                  items: items,
                  itemBuilder: (context, item) {
                    return SizedBox(
                      height: itemHeight,
                      child: Text('Tile $item'),
                    );
                  },
                  hasReachedMax: true,
                  onFetch: mockOnFetch,
                )
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
      expect(find.text('Tile 0'), findsOneWidget);
      expect(find.text('Tile 19'), findsNothing);
      expect(find.byType(BottomLoader), findsNothing);
      verifyNever(() => mockOnFetch());

      controller.jumpTo(scrollPosition);
      await tester.pump();

      expect(find.text('Tile 0'), findsNothing);
      expect(find.text('Tile 19'), findsOneWidget);
      expect(find.byType(BottomLoader), findsNothing);
      verifyNever(() => mockOnFetch());
    },
  );

  testWidgets(
    'InfiniteList should show loading indicator when loading',
    (tester) async {
      final List<int> items = List<int>.generate(20, (int i) => i);
      const double itemHeight = 300.0;
      const double viewportHeight = 500.0;
      const double scrollPosition = 19 * itemHeight;
      final ScrollController controller = ScrollController();
      final mockOnFetch = MockOnFetch();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: viewportHeight,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverInfiniteList<int>(
                  items: items,
                  itemBuilder: (context, item) {
                    return SizedBox(
                      height: itemHeight,
                      child: Text('Tile $item'),
                    );
                  },
                  hasReachedMax: false,
                  onFetch: mockOnFetch,
                )
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
      expect(find.text('Tile 0'), findsOneWidget);
      expect(find.text('Tile 19'), findsNothing);
      expect(find.byType(BottomLoader), findsNothing);
      verifyNever(() => mockOnFetch());

      controller.jumpTo(scrollPosition);
      await tester.pump();

      expect(find.text('Tile 0'), findsNothing);
      expect(find.text('Tile 19'), findsOneWidget);
      expect(find.byType(BottomLoader), findsOneWidget);
      verify(() => mockOnFetch()).called(1);
    },
  );
}
