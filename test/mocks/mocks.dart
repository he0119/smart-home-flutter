import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/core/repository/push_repository.dart';
import 'package:smarthome/core/repository/settings_repository.dart';
import 'package:smarthome/core/repository/version_repository.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/user/repository/user_repository.dart';

// 生成 Mock 类
// 运行 `dart run build_runner build` 来生成 mocks.mocks.dart
@GenerateMocks([
  GraphQLApiClient,
  UserRepository,
  SettingsRepository,
  StorageRepository,
  BoardRepository,
  PushRepository,
  VersionRepository,
  GoRouter,
])
void main() {}
