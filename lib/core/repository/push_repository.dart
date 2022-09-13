import 'package:android_id/android_id.dart';
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
    final options = QueryOptions(
      document: gql(miPushKeyQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final Map<String, dynamic> json = results.data!['miPushKey'];
    final miPushKeyObject = MiPushKey.fromJson(json);
    return miPushKeyObject;
  }

  /// MiPush
  Future<MiPush> miPush() async {
    const androidId = AndroidId();

    final options = QueryOptions(
      document: gql(miPushQuery),
      variables: {
        'deviceId': await androidId.getId(),
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final Map<String, dynamic> json = results.data!['miPush'];
    final miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }

  /// 更新 MiPush 的 RegId
  Future<MiPush> updateMiPush({
    required String regId,
  }) async {
    final deviceInfo = DeviceInfoPlugin();
    const androidId = AndroidId();
    final androidInfo = await deviceInfo.androidInfo;
    final options = MutationOptions(
      document: gql(updateMiPushMutation),
      variables: {
        'input': {
          'regId': regId,
          'deviceId': await androidId.getId(),
          'model': androidInfo.model,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['updateMiPush'];
    final miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }
}
