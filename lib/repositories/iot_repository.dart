import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';

import 'package:smart_home/graphql/mutations/iot/mutations.dart';
import 'package:smart_home/graphql/queries/iot/queries.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class IotRepository {
  final GraphQLApiClient graphqlApiClient;

  IotRepository({
    @required this.graphqlApiClient,
  });

  /// 设备数据
  ///
  /// 永远不缓存
  Future<List<AutowateringData>> deviceData({
    @required String deviceId,
    int number,
  }) async {
    QueryOptions _options = QueryOptions(
      document: gql(deviceDataQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    QueryResult results = await graphqlApiClient.query(_options);

    final List<dynamic> deviceData = results.data['autowateringData']['edges'];
    final List<AutowateringData> listofAutowateringData = deviceData
        .map((dynamic e) => AutowateringData.fromJson(e['node']))
        .toList();
    return listofAutowateringData;
  }

  Future<Device> addDevice({
    @required String name,
    @required String deviceType,
    String location,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addDeviceMutation),
      variables: {
        'input': {
          'name': name,
          'deviceType': deviceType,
          'location': location,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addDevice']['device'];
    final Device deviceObject = Device.fromJson(json);
    return deviceObject;
  }

  Future<Device> setDevice({
    @required String id,
    @required String key,
    @required String value,
    @required String valueType,
    String location,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(setDeviceMutation),
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
    final Map<String, dynamic> json = result.data['setDevice']['device'];
    final Device deviceObject = Device.fromJson(json);
    return deviceObject;
  }

  Future<String> deleteDevice({@required String deviceId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteDeviceMutation),
      variables: {
        'input': {'deviceId': deviceId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data['deleteDevice']['deviceId'];
  }

  Future<Device> updateDevice({
    @required String id,
    String name,
    String deviceType,
    String location,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(updateDeviceMutation),
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
    final Map<String, dynamic> json = result.data['updateDevice']['device'];
    final Device deviceObject = Device.fromJson(json);
    return deviceObject;
  }
}
