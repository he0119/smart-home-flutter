import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/core/repository/push_repository.dart';
import 'package:smarthome/core/repository/settings_repository.dart';
import 'package:smarthome/core/repository/version_repository.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/user/repository/user_repository.dart';

part 'repository_providers.g.dart';

/// Settings Repository Provider
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository();
}

/// GraphQL API Client Provider
@Riverpod(keepAlive: true)
GraphQLApiClient graphQLApiClient(Ref ref) {
  return GraphQLApiClient(ref);
}

/// User Repository Provider
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return UserRepository(graphqlApiClient: graphqlApiClient);
}

/// Version Repository Provider
@Riverpod(keepAlive: true)
VersionRepository versionRepository(Ref ref) {
  return VersionRepository();
}

/// Push Repository Provider
@Riverpod(keepAlive: true)
PushRepository pushRepository(Ref ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return PushRepository(graphqlApiClient: graphqlApiClient);
}

/// Storage Repository Provider
@Riverpod(keepAlive: true)
StorageRepository storageRepository(Ref ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return StorageRepository(graphqlApiClient: graphqlApiClient);
}

/// Board Repository Provider
@Riverpod(keepAlive: true)
BoardRepository boardRepository(Ref ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return BoardRepository(graphqlApiClient: graphqlApiClient);
}
