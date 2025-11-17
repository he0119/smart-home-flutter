import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/core/repository/push_repository.dart';
import 'package:smarthome/core/repository/version_repository.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/user/repository/user_repository.dart';

/// GraphQL API Client Provider
final graphQLApiClientProvider = Provider<GraphQLApiClient>((ref) {
  throw UnimplementedError('Override in bootstrap');
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return UserRepository(graphqlApiClient: graphqlApiClient);
});

/// Version Repository Provider
final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  return VersionRepository();
});

/// Push Repository Provider
final pushRepositoryProvider = Provider<PushRepository>((ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return PushRepository(graphqlApiClient: graphqlApiClient);
});

/// Storage Repository Provider
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return StorageRepository(graphqlApiClient: graphqlApiClient);
});

/// Board Repository Provider
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return BoardRepository(graphqlApiClient: graphqlApiClient);
});
