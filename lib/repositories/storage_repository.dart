import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
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
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e)).toList();
    final List<Item> listofItem =
        items.map((dynamic e) => Item.fromJson(e)).toList();
    return [listofItem, listofStorage];
  }

  Future<List<Storage>> rootStorage() async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(rootStorageQuery),
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> storages = results.data['rootStorage'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e)).toList();
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
    final Map<String, dynamic> json = result.data['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<List<Storage>> storages() async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(storagesQuery),
    );
    final result = await graphqlApiClient.query(options);
    final List<dynamic> storages = result.data['storages'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e)).toList();
    return listofStorage;
  }

  Future<Item> item(String id) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(itemQuery),
      variables: {
        'id': id,
      },
    );
    final result = await graphqlApiClient.query(options);
    final Map<String, dynamic> json = result.data['item'];
    final Item itemObject = Item.fromJson(json);
    return itemObject;
  }

  Future<Item> updateItem({
    @required String id,
    String name,
    int number,
    String storageId,
    String description,
    double price,
    DateTime expirationDate,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateItemMutation),
      variables: {
        'input': {
          'id': id,
          'name': name,
          'number': number,
          'storage': {'id': storageId},
          'description': description,
          'price': price,
          'expirationDate': expirationDate?.toIso8601String(),
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateItem']['item'];
    final Item itemObject = Item.fromJson(json);
    return itemObject;
  }

  Future<Item> addItem(Item item) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addItemMutation),
      variables: {'input': item.toJson()},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addItem']['item'];
    final Item itemObject = Item.fromJson(json);
    return itemObject;
  }

  Future<Storage> updateStorage(Storage storage) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateStorageMutation),
      variables: {'input': storage.toJson()},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<Storage> addStorage(Storage storage) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addStorageMutation),
      variables: {'input': storage.toJson()},
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }
}
