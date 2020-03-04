import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/serializers.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

StorageRepository storageRepository = StorageRepository();

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
}

class StorageRepository {
  Future<List<dynamic>> search(String key) async {
    if (key == '') {
      return null;
    }
    final QueryOptions options = QueryOptions(
      documentNode:
          gql(searchQuery), // this is the query string you just created
      variables: {
        'key': key,
      },
    );
    final results = await graphqlApiClient.query(options);
    if (results.hasException) {
      throw StorageException('搜索出错');
    }
    final List<dynamic> storages = results.data['search']['storages'];
    final List<dynamic> items = results.data['search']['items'];
    final List<Storage> listofStorage = storages
        .map((dynamic e) => serializers.deserializeWith(Storage.serializer, e))
        .toList();
    final List<Item> listofItem = items
        .map((dynamic e) => serializers.deserializeWith(Item.serializer, e))
        .toList();
    return [listofItem, listofStorage];
  }

  Future<List<Storage>> rootStorage() async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(rootStorageQuery),
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> storages = results.data['rootStorage'];
    final List<Storage> listofStorage = storages
        .map((dynamic e) => serializers.deserializeWith(Storage.serializer, e))
        .toList();
    return listofStorage;
  }

  Future<Storage> storage(String id) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(storageQuery),
      variables: {
        'id': id,
      },
    );
    final result = await graphqlApiClient.query(options);
    final dynamic json = result.data['storage'];
    final Storage storageObject =
        serializers.deserializeWith(Storage.serializer, json);
    return storageObject;
  }

  Future<Item> item(String id) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(itemQuery),
      variables: {
        'id': id,
      },
    );
    final result = await graphqlApiClient.query(options);
    final dynamic json = result.data['item'];
    final Item itemObject = serializers.deserializeWith(Item.serializer, json);
    return itemObject;
  }

  Future<Item> updateItem(Item item) async {
    Map<String, dynamic> variables =
        serializers.serializeWith(Item.serializer, item);
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateItemMutation),
      variables: {'input': variables},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateItem'];
    final Item itemObject = serializers.deserializeWith(Item.serializer, json);
    return itemObject;
  }

  Future<Item> addItem(Item item) async {
    Map<String, dynamic> variables =
        serializers.serializeWith(Item.serializer, item);
    final MutationOptions options = MutationOptions(
      documentNode: gql(addItemMutation),
      variables: {'input': variables},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addItem'];
    final Item itemObject = serializers.deserializeWith(Item.serializer, json);
    return itemObject;
  }

  Future<Storage> updateStorage(Storage storage) async {
    Map<String, dynamic> variables =
        serializers.serializeWith(Storage.serializer, storage);
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateStorageMutation),
      variables: {'input': variables},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateStorage'];
    final Storage storageObject =
        serializers.deserializeWith(Storage.serializer, json);
    return storageObject;
  }

  Future<Storage> addStorage(Storage storage) async {
    Map<String, dynamic> variables =
        serializers.serializeWith(Storage.serializer, storage);
    final MutationOptions options = MutationOptions(
      documentNode: gql(addStorageMutation),
      variables: {'input': variables},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addStorage'];
    final Storage storageObject =
        serializers.deserializeWith(Storage.serializer, json);
    return storageObject;
  }
}
