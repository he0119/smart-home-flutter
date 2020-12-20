import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:smart_home/graphql/mutations/storage/mutations.dart';
import 'package:smart_home/graphql/queries/storage/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:tuple/tuple.dart';

class StorageRepository {
  final GraphQLApiClient graphqlApiClient;

  StorageRepository({@required this.graphqlApiClient});

  Future<Item> addItem({
    @required String name,
    @required int number,
    @required String storageId,
    String description,
    double price,
    DateTime expirationDate,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addItemMutation),
      variables: {
        'input': {
          'name': name,
          'number': number,
          'storageId': storageId,
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

  Future<Storage> addStorage({
    @required String name,
    String parentId,
    String description,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addStorageMutation),
      variables: {
        'input': {
          'name': name,
          'parentId': parentId != null ? parentId : null,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<void> deleteItem({String itemId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteItemMutation),
      variables: {
        'input': {
          'itemId': itemId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<void> deleteStorage({String storageId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteStorageMutation),
      variables: {
        'input': {
          'storageId': storageId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<List<Item>> expiredItems({String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(expiredItemsQuery),
      variables: {
        'after': after,
        'now': DateTime.now().toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> expiredItems = results.data['expiredItems']['edges'];
    final List<Item> listofExpiredItems =
        expiredItems.map((dynamic e) => Item.fromJson(e['node'])).toList();

    return listofExpiredItems;
  }

  /// 存储管理主页所需要的数据
  /// 过期，即将过期和最近添加，更新的物品
  Future<Map<String, List<Item>>> homePage({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(homepageQuery),
      variables: {
        'now': DateTime.now().toIso8601String(),
        'nearExpiredTime':
            DateTime.now().add(Duration(days: 180)).toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyAddedItems =
        results.data['recentlyAddedItems']['edges'];
    final List<Item> listofRecentlyAddedItems = recentlyAddedItems
        .map((dynamic e) => Item.fromJson(e['node']))
        .toList();

    final List<dynamic> recentlyUpdatedItems =
        results.data['recentlyUpdatedItems']['edges'];
    final List<Item> listofRecentlyUpdatedItems = recentlyUpdatedItems
        .map((dynamic e) => Item.fromJson(e['node']))
        .toList();

    final List<dynamic> expiredItems = results.data['expiredItems']['edges'];
    final List<Item> listofExpiredItems =
        expiredItems.map((dynamic e) => Item.fromJson(e['node'])).toList();

    final List<dynamic> nearExpiredItems =
        results.data['nearExpiredItems']['edges'];
    final List<Item> listofNearExpiredItems =
        nearExpiredItems.map((dynamic e) => Item.fromJson(e['node'])).toList();

    return {
      'recentlyAddedItems': listofRecentlyAddedItems,
      'recentlyUpdatedItems': listofRecentlyUpdatedItems,
      'expiredItems': listofExpiredItems,
      'nearExpiredItems': listofNearExpiredItems,
    };
  }

  Future<Item> item({@required String id, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(itemQuery),
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

  Future<List<Item>> nearExpiredItems({String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(nearExpiredItemsQuery),
      variables: {
        'after': after,
        'now': DateTime.now().toIso8601String(),
        'nearExpiredTime':
            DateTime.now().add(Duration(days: 180)).toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> nearExpiredItems =
        results.data['nearExpiredItems']['edges'];
    final List<Item> listofNearExpiredItems =
        nearExpiredItems.map((dynamic e) => Item.fromJson(e['node'])).toList();

    return listofNearExpiredItems;
  }

  Future<List<Item>> recentlyAddedItems(
      {String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(recentlyAddedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyAddedItems =
        results.data['recentlyAddedItems']['edges'];
    final List<Item> listofRecentlyAddedItems = recentlyAddedItems
        .map((dynamic e) => Item.fromJson(e['node']))
        .toList();

    return listofRecentlyAddedItems;
  }

  Future<List<Item>> recentlyUpdatedItems(
      {String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(recentlyUpdatedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyUpdatedItems =
        results.data['recentlyUpdatedItems']['edges'];
    final List<Item> listofRecentlyUpdatedItems = recentlyUpdatedItems
        .map((dynamic e) => Item.fromJson(e['node']))
        .toList();

    return listofRecentlyUpdatedItems;
  }

  Future<List<Storage>> rootStorage({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(rootStorageQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> storages = results.data['rootStorage']['edges'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e['node'])).toList();
    return listofStorage;
  }

  Future<List<dynamic>> search(String key) async {
    final QueryOptions options = QueryOptions(
      document: gql(searchQuery),
      variables: {'key': key},
      fetchPolicy: FetchPolicy.noCache,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> storageName = results.data['storageName']['edges'];
    final List<dynamic> storageDescription =
        results.data['storageDescription']['edges'];
    final List<dynamic> itemName = results.data['itemName']['edges'];
    final List<dynamic> itemDescription =
        results.data['itemDescription']['edges'];

    final List<Storage> listofStorageName =
        storageName.map((dynamic e) => Storage.fromJson(e['node'])).toList();
    final List<Storage> listofStorageDescription = storageDescription
        .map((dynamic e) => Storage.fromJson(e['node']))
        .toList();
    final List<Item> listofItemName =
        itemName.map((dynamic e) => Item.fromJson(e['node'])).toList();
    final List<Item> listofItemDescription =
        itemDescription.map((dynamic e) => Item.fromJson(e['node'])).toList();

    // 去重
    final List<Storage> listofStorage =
        (listofStorageName + listofStorageDescription).toSet().toList();
    final List<Item> listofItem =
        (listofItemName + listofItemDescription).toSet().toList();
    return [listofItem, listofStorage];
  }

  Future<Tuple6<Storage, List<Storage>, String, bool, String, bool>> storage({
    @required String id,
    String storageCursor,
    String itemCursor,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(storageQuery),
      variables: {
        'id': id,
        'itemCursor': itemCursor,
        'storageCursor': storageCursor,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    // 是否还有下一页
    final String stroageEndCursor =
        result.data['storage']['children']['pageInfo']['endCursor'];
    final bool stroageHasNextPage =
        result.data['storage']['children']['pageInfo']['hasNextPage'];
    final String itemEndCursor =
        result.data['storage']['items']['pageInfo']['endCursor'];
    final bool itemHasNextPage =
        result.data['storage']['items']['pageInfo']['hasNextPage'];

    // 位置详情
    final Map<String, dynamic> json = result.data['storage'];
    List<dynamic> children = json['children']['edges'];
    if (children.isNotEmpty) {
      final newchildren = children.map((dynamic e) => e['node']).toList();
      json['children'] = newchildren;
    } else {
      json['children'] = [];
    }
    List<dynamic> items = json['items']['edges'];
    if (items.isNotEmpty) {
      final newitems = items.map((dynamic e) => e['node']).toList();
      json['items'] = newitems;
    } else {
      json['items'] = [];
    }

    final Storage storageObject = Storage.fromJson(json);

    // 当前位置的上级节点
    final List<dynamic> ancestors = result.data['storageAncestors']['edges'];
    final List<Storage> listofAncestors =
        ancestors.map((dynamic e) => Storage.fromJson(e['node'])).toList();

    return Tuple6(
      storageObject,
      listofAncestors,
      stroageEndCursor,
      stroageHasNextPage,
      itemEndCursor,
      itemHasNextPage,
    );
  }

  Future<List<Storage>> storages({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(storagesQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);
    final List<dynamic> storages = result.data['storages']['edges'];
    final List<Storage> listofStorage =
        storages.map((dynamic e) => Storage.fromJson(e['node'])).toList();
    return listofStorage;
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
      document: gql(updateItemMutation),
      variables: {
        'input': {
          'id': id,
          'name': name,
          'number': number,
          'storageId': storageId,
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

  Future<Storage> updateStorage({
    @required String id,
    String name,
    String parentId,
    String description,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(updateStorageMutation),
      variables: {
        'input': {
          'id': id,
          'name': name,
          'parentId': parentId != null ? parentId : null,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateStorage']['storage'];
    final Storage storageObject = Storage.fromJson(json);
    return storageObject;
  }
}
