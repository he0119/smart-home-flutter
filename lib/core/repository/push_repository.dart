import 'package:device_info_plus/device_info_plus.dart';
import 'package:graphql/client.dart';
import 'package:smarthome/core/graphql/mutations/push/mutations.dart';
import 'package:smarthome/core/graphql/queries/push/queries.dart';
import 'package:smarthome/core/model/push.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';

class PushRepository {
  final GraphQLApiClient graphqlApiClient;

  PushRepository({
    required this.graphqlApiClient,
  });

  /// MiPushKey
  Future<MiPushKey> miPushKey() async {
    final _options = QueryOptions(
      document: gql(miPushKeyQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(_options);
    final Map<String, dynamic> json = results.data!['miPushKey'];
    final miPushKeyObject = MiPushKey.fromJson(json);
    return miPushKeyObject;
  }

  /// MiPush
  Future<MiPush> miPush() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final _options = QueryOptions(
      document: gql(miPushQuery),
      variables: {
        'deviceId': androidInfo.androidId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(_options);
    final Map<String, dynamic> json = results.data!['miPush'];
    final miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }

  /// 更新 MiPush 的 RegId
  Future<MiPush> updateMiPush({
    required String regId,
  }) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final options = MutationOptions(
      document: gql(updateMiPushMutation),
      variables: {
        'input': {
          'regId': regId,
          'deviceId': androidInfo.androidId,
          'model': androidInfo.model,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['updateMiPush']['miPush'];
    final miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }
}
