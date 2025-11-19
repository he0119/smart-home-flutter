import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome/core/core.dart';

void main() {
  test('appConfigProvider throws if it is not overridden', () {
    final container = ProviderContainer();

    expect(
      () => container.read(appConfigProvider),
      throwsA(
        isA<Object>().having(
          (error) => error.toString(),
          'message',
          contains('UnimplementedError'),
        ),
      ),
    );

    container.dispose();
  });
}
