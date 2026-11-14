import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/search_page.dart';
import 'package:tuple/tuple.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  testWidgets('searching with no hits shows the empty state', (tester) async {
    final repository = MockStorageRepository();
    when(
      repository.search(
        any,
        isDeleted: anyNamed('isDeleted'),
        missingStorage: anyNamed('missingStorage'),
      ),
    ).thenAnswer((_) async => const Tuple2(<Item>[], <Storage>[]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: buildLightTheme(null),
          home: const SearchScreen(),
        ),
      ),
    );

    expect(find.byType(SearchBar), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(SearchBar),
        matching: find.byType(TextField),
      ),
      '雨伞',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('没有找到相关内容'), findsOneWidget);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });
}
