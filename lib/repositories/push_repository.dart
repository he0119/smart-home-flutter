import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/push/mutations.dart';
import 'package:smart_home/graphql/queries/push/queries.dart';
import 'package:smart_home/models/push.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class PushRepository {
  final GraphQLApiClient graphqlApiClient;

  PushRepository({@required this.graphqlApiClient});

  /// MiPushKey
  Future<MiPushKey> miPushKey() async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(miPushKeyQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    QueryResult results = await graphqlApiClient.query(_options);
    final Map<String, dynamic> json = results.data['miPushKey'];
    final MiPushKey miPushKeyObject = MiPushKey.fromJson(json);
    return miPushKeyObject;
  }

  /// MiPush
  Future<MiPush> miPush() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    QueryOptions _options = QueryOptions(
      documentNode: gql(miPushQuery),
      variables: {
        'deviceId': androidInfo.androidId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    QueryResult results = await graphqlApiClient.query(_options);
    final Map<String, dynamic> json = results.data['miPush'];
    final MiPush miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }

  /// 更新 MiPush 的 RegId
  Future<MiPush> updateMiPush({
    @required String regId,
  }) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateMiPushMutation),
      variables: {
        'input': {
          'regId': regId,
          'deviceId': androidInfo.androidId,
          'model': androidInfo.model,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateMiPush']['miPush'];
    final MiPush miPushObject = MiPush.fromJson(json);
    return miPushObject;
  }
}
