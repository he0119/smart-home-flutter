import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/repository/settings_repository.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const {});
  });

  test('searchHistory returns saved terms', () async {
    SharedPreferences.setMockInitialValues({
      'searchHistory': ['keyboard', 'router'],
    });
    final repository = SettingsRepository();

    expect(await repository.searchHistory(), ['keyboard', 'router']);
  });

  test('updateSearchHistory limits saved terms', () async {
    final repository = SettingsRepository();
    final terms = List.generate(25, (index) => 'term-$index');

    await repository.updateSearchHistory(terms);

    expect(await repository.searchHistory(), terms.take(20));
  });

  test('clearSearchHistory removes saved terms', () async {
    SharedPreferences.setMockInitialValues({
      'searchHistory': ['keyboard'],
    });
    final repository = SettingsRepository();

    await repository.clearSearchHistory();

    expect(await repository.searchHistory(), isEmpty);
  });
}
