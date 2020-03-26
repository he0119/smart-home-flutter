import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/storage/mutations.dart';
import 'package:smart_home/graphql/queries/storage/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

StorageRepository storageRepository = StorageRepository();

class StorageRepository {
  Future<List<dynamic>> search(String key) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(searchQuery),
      variables: {'key': key},
      fetchPolicy: FetchPolicy.noCache,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> storages = results.data['search']['storages'];
    final List<dynamic> items = results.data['search']['items'];
    final List<Storage> listofStorage =
        storages.map((dynamic json) => Storage.fromJson(json)).toList();
    final List<Item> listofItem =
        items.map((dynamic json) => Item.fromJson(json)).toList();
    return [listofItem, listofStorage];
  }

  /// 存储管理主页所需要的数据
  /// 过期，即将过期和最近添加，更新的物品
  Future<Map<String, List<Item>>> homePage({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(homepageQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyAddedItems = results.data['recentlyAddedItems'];
    final List<Item> listofRecentlyAddedItems =
        recentlyAddedItems.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> recentlyUpdatedItems =
        results.data['recentlyUpdatedItems'];
    final List<Item> listofRecentlyUpdatedItems =
        recentlyUpdatedItems.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> expiredItems = results.data['expiredItems'];
    final List<Item> listofExpiredItems =
        expiredItems.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> nearExpiredItems = results.data['nearExpiredItems'];
    final List<Item> listofNearExpiredItems =
        nearExpiredItems.map((dynamic e) => Item.fromJson(e)).toList();

    return {
      'recentlyAddedItems': listofRecentlyAddedItems,
      'recentlyUpdatedItems': listofRecentlyUpdatedItems,
      'expiredItems': listofExpiredItems,
      'nearExpiredItems': listofNearExpiredItems,
    };
  }

  Future<List<Item>> recentlyAddedItems(
      {@required int number, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(recentlyAddedItemsQuery),
      variables: {
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyAddedItems = results.data['recentlyAddedItems'];
    assert(recentlyAddedItems != null);
    final List<Item> listofRecentlyAddedItems =
        recentlyAddedItems.map((dynamic e) => Item.fromJson(e)).toList();

    return listofRecentlyAddedItems;
  }

  Future<List<Item>> recentlyUpdatedItems(
      {@required int number, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(recentlyUpdatedItemsQuery),
      variables: {
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyUpdatedItems =
        results.data['recentlyUpdatedItems'];
    assert(recentlyUpdatedItems != null);
    final List<Item> listofRecentlyUpdatedItems =
        recentlyUpdatedItems.map((dynamic e) => Item.fromJson(e)).toList();

    return listofRecentlyUpdatedItems;
  }

  Future<List<Item>> expiredItems({int number, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(expiredItemsQuery),
      variables: {
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> expiredItems = results.data['expiredItems'];
    assert(expiredItems != null);
    final List<Item> listofExpiredItems =
        expiredItems.map((dynamic e) => Item.fromJson(e)).toList();

    return listofExpiredItems;
  }

  Future<List<Item>> nearExpiredItems(
      {@required int within, int number, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(nearExpiredItemsQuery),
      variables: {
        'within': within,
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> nearExpiredItems = results.data['nearExpiredItems'];
    assert(nearExpiredItems != null);
    final List<Item> listofNearExpiredItems =
        nearExpiredItems.map((dynamic e) => Item.fromJson(e)).toList();

    return listofNearExpiredItems;
  }

  Future<List<Storage>> rootStorage({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(rootStorageQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> storages = results.data['rootStorage'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e)).toList();
    return listofStorage;
  }

  Future<Map<String, dynamic>> storage(
      {@required String id, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(storageQuery),
      variables: {
        'id': id,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);
    final Map<String, dynamic> json = result.data['storage'];
    final Storage storageObject = Storage.fromJson(json);
    final List<dynamic> ancestors = result.data['storageAncestors'];
    final List<Storage> listofAncestors =
        ancestors.map((dynamic e) => Storage.fromJson(e)).toList();
    return {
      'storage': storageObject,
      'ancestors': listofAncestors,
    };
  }

  Future<List<Storage>> storages({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(storagesQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);
    final List<dynamic> storages = result.data['storages'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e)).toList();
    return listofStorage;
  }

  Future<Item> item({@required String id, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(itemQuery),
      variables: {
        'id': id,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
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

  Future<String> deleteItem({String id}) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(deleteItemMutation),
      variables: {
        'id': id,
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final String deletedId = result.data['deletedId'];
    return deletedId;
  }

  Future<Item> addItem({
    @required String name,
    @required int number,
    @required String storageId,
    String description,
    double price,
    DateTime expirationDate,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addItemMutation),
      variables: {
        'input': {
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
    final Map<String, dynamic> json = result.data['addItem']['item'];
    final Item itemObject = Item.fromJson(json);
    return itemObject;
  }

  Future<Storage> updateStorage({
    @required String id,
    String name,
    String parentId,
    String description,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateStorageMutation),
      variables: {
        'input': {
          'id': id,
          'name': name,
          'parent': parentId != null ? {'id': parentId} : null,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<Storage> addStorage({
    @required String name,
    String parentId,
    String description,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addStorageMutation),
      variables: {
        'input': {
          'name': name,
          'parent': parentId != null ? {'id': parentId} : null,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<String> deleteStorage({String id}) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(deleteStorageMutation),
      variables: {
        'id': id,
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final String deletedId = result.data['deletedId'];
    return deletedId;
  }
}
