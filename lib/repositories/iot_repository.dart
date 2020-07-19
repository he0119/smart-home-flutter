import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/iot/mutations.dart';
import 'package:smart_home/graphql/queries/iot/queries.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class IotRepository {
  final GraphQLApiClient graphqlApiClient;

  IotRepository({@required this.graphqlApiClient});

  Future<AutowateringData> deviceData({
    @required String deviceId,
    int number,
  }) async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(deviceDataQuery),
      variables: {
        'deviceId': deviceId,
        'number': number,
      },
    );
    QueryResult results = await graphqlApiClient.query(_options);
    AutowateringData data =
        AutowateringData.fromJson(results.data['deviceData']);
    return data;
  }

  Future<Device> addDevice({
    @required String name,
    @required String deviceType,
    String location,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addDeviceMutation),
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
      documentNode: gql(setDeviceMutation),
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
      documentNode: gql(deleteDeviceMutation),
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
      documentNode: gql(updateDeviceMutation),
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
