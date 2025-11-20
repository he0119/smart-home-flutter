import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/core.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockGraphQLApiClient mockGraphQLApiClient;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const {});
  });

  setUp(() {
    mockGraphQLApiClient = MockGraphQLApiClient();
    container = ProviderContainer.test(
      overrides: [
        graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('settingsRepositoryProvider returns SettingsRepository', () {
    final repository = container.read(settingsRepositoryProvider);
    expect(repository, isA<SettingsRepository>());
  });

  test('graphQLApiClientProvider returns GraphQLApiClient instance', () {
    final client = container.read(graphQLApiClientProvider);
    expect(client, isA<GraphQLApiClient>());
  });

  test('userRepositoryProvider uses graphQLApiClientProvider', () {
    final repository = container.read(userRepositoryProvider);
    expect(repository.graphqlApiClient, mockGraphQLApiClient);
  });

  test('pushRepositoryProvider uses graphQLApiClientProvider', () {
    final repository = container.read(pushRepositoryProvider);
    expect(repository.graphqlApiClient, mockGraphQLApiClient);
  });

  test('storageRepositoryProvider uses graphQLApiClientProvider', () {
    final repository = container.read(storageRepositoryProvider);
    expect(repository.graphqlApiClient, mockGraphQLApiClient);
  });

  test('boardRepositoryProvider uses graphQLApiClientProvider', () {
    final repository = container.read(boardRepositoryProvider);
    expect(repository.graphqlApiClient, mockGraphQLApiClient);
  });

  test('versionRepositoryProvider returns VersionRepository', () {
    final repository = container.read(versionRepositoryProvider);
    expect(repository, isA<VersionRepository>());
  });
}
