import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockGoRouter mockGoRouter;
  late ProviderContainer container;

  setUp(() {
    mockGoRouter = MockGoRouter();
    container = ProviderContainer.test(
      overrides: [routerProvider.overrideWithValue(mockGoRouter)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is null', () {
    expect(container.read(tabProvider), isNull);
  });

  test('setTab updates the state and triggers navigation', () {
    when(mockGoRouter.go(any)).thenAnswer((_) {});

    container.read(tabProvider.notifier).setTab(AppTab.blog);

    expect(container.read(tabProvider), AppTab.blog);
    verify(mockGoRouter.go(AppTab.blog.route)).called(1);
  });

  test('setTab(null) resets the state without navigation', () {
    when(mockGoRouter.go(any)).thenAnswer((_) {});

    container.read(tabProvider.notifier).setTab(null);

    expect(container.read(tabProvider), isNull);
    verifyNever(mockGoRouter.go(any));
  });
}
