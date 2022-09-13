import 'package:graphql/client.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/graphql/mutations/mutations.dart';
import 'package:smarthome/iot/graphql/queries/queries.dart';
import 'package:smarthome/iot/model/iot.dart';

class IotRepository {
  final GraphQLApiClient graphqlApiClient;

  IotRepository({
    required this.graphqlApiClient,
  });

  /// 设备数据
  ///
  /// 永远不缓存
  Future<List<AutowateringData>> autowateringData({
    required String deviceId,
    int? number,
  }) async {
    final options = QueryOptions(
      document: gql(deviceDataQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> deviceData = results.data!['autowateringData']['edges'];
    final listofAutowateringData = deviceData
        .map((dynamic e) => AutowateringData.fromJson(e['node']))
        .toList();
    return listofAutowateringData;
  }

  Future<Device> addDevice({
    required String name,
    required String deviceType,
    String? location,
  }) async {
    final options = MutationOptions(
      document: opi(gql(addDeviceMutation)),
      variables: {
        'input': {
          'name': name,
          'deviceType': deviceType,
          'location': location,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['addDevice'];
    final deviceObject = Device.fromJson(json);
    return deviceObject;
  }

  Future<Device> setDevice({
    required String id,
    required String key,
    required String value,
    required String valueType,
    String? location,
  }) async {
    final options = MutationOptions(
      document: opi(gql(setDeviceMutation)),
      variables: {
        'input': {
          'id': id,
          'key': key,
          'value': value,
          'valueType': valueType,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['setDevice'];
    final deviceObject = Device.fromJson(json);
    return deviceObject;
  }

  Future<String?> deleteDevice({required String deviceId}) async {
    final options = MutationOptions(
      document: opi(gql(deleteDeviceMutation)),
      variables: {
        'input': {'deviceId': deviceId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data!['deleteDevice']['id'];
  }

  Future<Device> updateDevice({
    required String id,
    String? name,
    String? deviceType,
    String? location,
  }) async {
    final options = MutationOptions(
      document: opi(gql(updateDeviceMutation)),
      variables: {
        'input': {
          'id ': id,
          'name': name,
          'deviceType': deviceType,
          'location': location,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['updateDevice'];
    final deviceObject = Device.fromJson(json);
    return deviceObject;
  }
}
