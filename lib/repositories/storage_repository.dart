import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:smart_home/utils/graphql_helper.dart';
import 'package:tuple/tuple.dart';

import 'package:smart_home/graphql/mutations/storage/mutations.dart';
import 'package:smart_home/graphql/queries/storage/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class StorageRepository {
  final GraphQLApiClient graphqlApiClient;

  StorageRepository({
    @required this.graphqlApiClient,
  });

  Future<Item> addItem({
    @required String name,
    @required int number,
    @required String storageId,
    String description,
    double price,
    DateTime expiredAt,
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
          'expiredAt': expiredAt?.toIso8601String(),
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

  Future<Item> addConsumable({
    @required String id,
    List<String> consumableIds,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addConsumableMutation),
      variables: {
        'input': {
          'id': id,
          'consumableIds': consumableIds,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> itemJson =
        result.data.flattenConnection['addConsumable']['item'];

    final Item item = Item.fromJson(itemJson);
    return item;
  }

  Future<Item> deleteConsumable({
    @required String id,
    List<String> consumableIds,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteConsumableMutation),
      variables: {
        'input': {
          'id': id,
          'consumableIds': consumableIds,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> itemJson =
        result.data.flattenConnection['deleteConsumable']['item'];

    final Item item = Item.fromJson(itemJson);
    return item;
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

  Future<void> restoreItem({String itemId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(restoreItemMutation),
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

    final List<dynamic> expiredItemsJson =
        results.data.flattenConnection['expiredItems'];
    final List<Item> expiredItems =
        expiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return expiredItems;
  }

  Future<List<Item>> deletedItems({String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(deletedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> deletedItemsJson =
        results.data.flattenConnection['deletedItems'];
    final List<Item> deletedItems =
        deletedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return deletedItems;
  }

  /// 存储管理主页所需要的数据
  /// 过期，即将过期和最近录入，修改的物品
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

    final json = results.data.flattenConnection;

    final List<dynamic> recentlyCreatedItemsJson = json['recentlyCreatedItems'];
    final List<Item> recentlyCreatedItems =
        recentlyCreatedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> recentlyEditedItemsJson = json['recentlyEditedItems'];
    final List<Item> recentlyEditedItems =
        recentlyEditedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> expiredItemsJson = json['expiredItems'];
    final List<Item> expiredItems =
        expiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> nearExpiredItemsJson = json['nearExpiredItems'];
    final List<Item> nearExpiredItems =
        nearExpiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return {
      'recentlyCreatedItems': recentlyCreatedItems,
      'recentlyEditedItems': recentlyEditedItems,
      'expiredItems': expiredItems,
      'nearExpiredItems': nearExpiredItems,
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

    final Map<String, dynamic> itemJson = result.data.flattenConnection['item'];
    final Item item = Item.fromJson(itemJson);

    return item;
  }

  Future<Item> itemByName({@required String name, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(itemByNameQuery),
      variables: {
        'name': name,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    final List<dynamic> itemJson = result.data.flattenConnection['item'];
    if (itemJson.isEmpty) {
      return null;
    }
    final Item item = Item.fromJson(itemJson[0]);

    return item;
  }

  Future<List<Item>> items({
    String key,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(itemsQuery),
      variables: {
        'key': key,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    final List<dynamic> itemsJson = result.data.flattenConnection['items'];
    final List<Item> items =
        itemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return items;
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

    final List<dynamic> nearExpiredItemsJson =
        results.data.flattenConnection['nearExpiredItems'];
    final List<Item> nearExpiredItems =
        nearExpiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return nearExpiredItems;
  }

  Future<List<Item>> recentlyCreatedItems(
      {String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(recentlyCreatedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyCreatedItemsJson =
        results.data.flattenConnection['recentlyCreatedItems'];
    final List<Item> recentlyCreatedItems =
        recentlyCreatedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return recentlyCreatedItems;
  }

  Future<List<Item>> recentlyEditedItems(
      {String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(recentlyEditedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> recentlyEditedItemsJson =
        results.data.flattenConnection['recentlyEditedItems'];
    final List<Item> recentlyEditedItems =
        recentlyEditedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return recentlyEditedItems;
  }

  Future<List<Item>> consumables({String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(consumablesQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> consumablesJson =
        results.data.flattenConnection['consumables'];
    final List<Item> consumables =
        consumablesJson.map((dynamic e) => Item.fromJson(e)).toList();

    // 去重
    // FIXME: 这是服务器上的 bug
    // https://code.djangoproject.com/ticket/2361
    return consumables.toSet().toList();
  }

  Future<List<Storage>> rootStorage({bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(rootStorageQuery),
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> storagesJson =
        results.data.flattenConnection['rootStorage'];
    final List<Storage> storages =
        storagesJson.map((dynamic e) => Storage.fromJson(e)).toList();

    return storages;
  }

  Future<List<dynamic>> search(String key, {bool isDeleted = false}) async {
    final QueryOptions options = QueryOptions(
      document: gql(searchQuery),
      variables: {
        'key': key,
        'isDeleted': isDeleted,
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    final results = await graphqlApiClient.query(options);

    final json = results.data.flattenConnection;

    final List<dynamic> storageNameJson = json['storageName'];
    final List<dynamic> storageDescriptionJson = json['storageDescription'];
    final List<dynamic> itemNameJson = json['itemName'];
    final List<dynamic> itemDescriptionJson = json['itemDescription'];

    final List<Storage> storagesName =
        storageNameJson.map((dynamic e) => Storage.fromJson(e)).toList();
    final List<Storage> storagesDescription =
        storageDescriptionJson.map((dynamic e) => Storage.fromJson(e)).toList();
    final List<Item> itemsName =
        itemNameJson.map((dynamic e) => Item.fromJson(e)).toList();
    final List<Item> itemsDescription =
        itemDescriptionJson.map((dynamic e) => Item.fromJson(e)).toList();

    // 去重
    final List<Storage> storages =
        (storagesName + storagesDescription).toSet().toList();
    final List<Item> items = (itemsName + itemsDescription).toSet().toList();

    return [items, storages];
  }

  /// 获取位置详情信息
  /// 当前位置
  /// stroageEndCursor，stroageHasNextPage
  /// itemEndCursor，itemHasNextPage
  Future<Tuple5<Storage, String, bool, String, bool>> storage({
    @required String name,
    String id,
    String storageCursor,
    String itemCursor,
    bool cache = true,
  }) async {
    Map<String, dynamic> storageJson;

    if (id != null) {
      // 如果有 ID，则直接通过 ID 获取数据
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

      storageJson = result.data['storage'];
    } else {
      // 通过名称来获取数据
      final QueryOptions options = QueryOptions(
        document: gql(storageByNameQuery),
        variables: {
          'name': name,
          'itemCursor': itemCursor,
          'storageCursor': storageCursor,
        },
        fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
      );
      final result = await graphqlApiClient.query(options);

      Map<String, dynamic> storageListJson = result.data['storage'];
      if (storageListJson['edges'].isEmpty) {
        return null;
      }
      storageJson = storageListJson['edges'][0]['node'];
    }

    // 是否还有下一页
    final String stroageEndCursor =
        storageJson['children']['pageInfo']['endCursor'];
    final bool stroageHasNextPage =
        storageJson['children']['pageInfo']['hasNextPage'];
    final String itemEndCursor = storageJson['items']['pageInfo']['endCursor'];
    final bool itemHasNextPage =
        storageJson['items']['pageInfo']['hasNextPage'];

    // 位置详情
    final Map<String, dynamic> json = storageJson.flattenConnection;

    final Storage storage = Storage.fromJson(json);

    return Tuple5(
      storage,
      stroageEndCursor,
      stroageHasNextPage,
      itemEndCursor,
      itemHasNextPage,
    );
  }

  Future<List<Storage>> storages({
    String key,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(storagesQuery),
      variables: {
        'key': key,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    final List<dynamic> storagesJson =
        result.data.flattenConnection['storages'];
    final List<Storage> storages =
        storagesJson.map((dynamic e) => Storage.fromJson(e)).toList();

    return storages;
  }

  Future<Item> updateItem({
    @required String id,
    String name,
    int number,
    String storageId,
    String description,
    double price,
    DateTime expiredAt,
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
          'expiredAt': expiredAt?.toIso8601String(),
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);

    final Map<String, dynamic> itemJson = result.data['updateItem']['item'];
    final Item item = Item.fromJson(itemJson);

    return item;
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

    final Map<String, dynamic> storageJson =
        result.data['updateStorage']['storage'];
    final Storage storage = Storage.fromJson(storageJson);

    return storage;
  }
}
