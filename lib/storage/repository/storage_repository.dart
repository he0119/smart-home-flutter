import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/graphql/mutations/mutations.dart';
import 'package:smarthome/storage/graphql/queries/queries.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/graphql_helper.dart';
import 'package:tuple/tuple.dart';

class StorageRepository {
  final GraphQLApiClient graphqlApiClient;

  StorageRepository({
    required this.graphqlApiClient,
  });

  Future<Item> addConsumable({
    required String id,
    List<String>? consumableIds,
  }) async {
    final options = MutationOptions(
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
        result.data!.flattenConnection['addConsumable'];

    final item = Item.fromJson(itemJson);
    return item;
  }

  Future<Item> addItem({
    required String name,
    required int number,
    required String? storageId,
    String? description,
    double? price,
    DateTime? expiredAt,
  }) async {
    final options = MutationOptions(
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
    final Map<String, dynamic> json = result.data!['addItem'];
    final itemObject = Item.fromJson(json);
    return itemObject;
  }

  Future<Picture> addPicture({
    required String? itemId,
    required String picturePath,
    required double boxX,
    required double boxY,
    required double boxH,
    required double boxW,
    String? description,
  }) async {
    final myFile = await _getMultipartFile(picturePath);

    final options = MutationOptions(
      document: gql(addPictureMutation),
      variables: {
        'input': {
          'itemId': itemId,
          'file': myFile,
          'description': description,
          'boxX': boxX,
          'boxY': boxY,
          'boxH': boxH,
          'boxW': boxW,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['addPicture'];
    final pictureObject = Picture.fromJson(json);
    return pictureObject;
  }

  Future<Storage> addStorage({
    required String name,
    String? parentId,
    String? description,
  }) async {
    final options = MutationOptions(
      document: gql(addStorageMutation),
      variables: {
        'input': {
          'name': name,
          'parentId': parentId,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['addStorage'];
    final storageObject = Storage.fromJson(json);
    return storageObject;
  }

  Future<Tuple2<List<Item>, PageInfo>> consumables({
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(consumablesQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['consumables']['pageInfo']);

    final List<dynamic> consumablesJson =
        results.data!.flattenConnection['consumables'];
    final consumables =
        consumablesJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(consumables, pageInfo);
  }

  Future<Item> deleteConsumable({
    required String id,
    List<String>? consumableIds,
  }) async {
    final options = MutationOptions(
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
        result.data!.flattenConnection['deleteConsumable'];

    final item = Item.fromJson(itemJson);
    return item;
  }

  Future<Tuple2<List<Item>, PageInfo>> deletedItems(
      {String? after, bool cache = true}) async {
    final options = QueryOptions(
      document: gql(deletedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['deletedItems']['pageInfo']);

    final List<dynamic> deletedItemsJson =
        results.data!.flattenConnection['deletedItems'];
    final deletedItems =
        deletedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(deletedItems, pageInfo);
  }

  Future<void> deleteItem({String? itemId}) async {
    final options = MutationOptions(
      document: gql(deleteItemMutation),
      variables: {
        'input': {
          'itemId': itemId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<void> deletePicture({String? pictureId}) async {
    final options = MutationOptions(
      document: gql(deletePictureMutation),
      variables: {
        'input': {
          'pictureId': pictureId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<void> deleteStorage({String? storageId}) async {
    final options = MutationOptions(
      document: gql(deleteStorageMutation),
      variables: {
        'input': {
          'storageId': storageId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<Tuple2<List<Item>, PageInfo>> expiredItems({
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(expiredItemsQuery),
      variables: {
        'after': after,
        'now': DateTime.now().toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['expiredItems']['pageInfo']);

    final List<dynamic> expiredItemsJson =
        results.data!.flattenConnection['expiredItems'];
    final expiredItems =
        expiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(expiredItems, pageInfo);
  }

  /// 存储管理主页所需要的数据
  /// 过期，即将过期和最近录入，修改的物品
  Future<Map<String, List<Item>>> homePage({bool cache = true}) async {
    final options = QueryOptions(
      document: gql(homepageQuery),
      variables: {
        'now': DateTime.now().toIso8601String(),
        'nearExpiredTime':
            DateTime.now().add(const Duration(days: 180)).toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final json = results.data!.flattenConnection;

    final List<dynamic> recentlyCreatedItemsJson = json['recentlyCreatedItems'];
    final recentlyCreatedItems =
        recentlyCreatedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> recentlyEditedItemsJson = json['recentlyEditedItems'];
    final recentlyEditedItems =
        recentlyEditedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> expiredItemsJson = json['expiredItems'];
    final expiredItems =
        expiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    final List<dynamic> nearExpiredItemsJson = json['nearExpiredItems'];
    final nearExpiredItems =
        nearExpiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return {
      'recentlyCreatedItems': recentlyCreatedItems,
      'recentlyEditedItems': recentlyEditedItems,
      'expiredItems': expiredItems,
      'nearExpiredItems': nearExpiredItems,
    };
  }

  Future<Item?> item({
    required String id,
    bool cache = true,
  }) async {
    Map<String, dynamic>? itemJson;

    final options = QueryOptions(
      document: gql(itemQuery),
      variables: {
        'id': id,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    itemJson = result.data!['item'];

    if (itemJson == null) {
      return null;
    }

    final json = itemJson.flattenConnection;
    final item = Item.fromJson(json);

    return item;
  }

  Future<Picture?> picture({
    required String id,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(pictureQuery),
      variables: {
        'id': id,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    Map<String, dynamic> json = result.data!['picture'];

    final pictureObject = Picture.fromJson(json);

    return pictureObject;
  }

  Future<List<Item>> items({
    String? key,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(itemsQuery),
      variables: {
        'key': key,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    final List<dynamic> itemsJson = result.data!.flattenConnection['items'];
    final items = itemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return items;
  }

  Future<Tuple2<List<Item>, PageInfo>> nearExpiredItems({
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(nearExpiredItemsQuery),
      variables: {
        'after': after,
        'now': DateTime.now().toIso8601String(),
        'nearExpiredTime':
            DateTime.now().add(const Duration(days: 180)).toIso8601String(),
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['nearExpiredItems']['pageInfo']);

    final List<dynamic> nearExpiredItemsJson =
        results.data!.flattenConnection['nearExpiredItems'];
    final nearExpiredItems =
        nearExpiredItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(nearExpiredItems, pageInfo);
  }

  Future<Tuple2<List<Item>, PageInfo>> recentlyCreatedItems(
      {String? after, bool cache = true}) async {
    final options = QueryOptions(
      document: gql(recentlyCreatedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['recentlyCreatedItems']['pageInfo']);

    final List<dynamic> recentlyCreatedItemsJson =
        results.data!.flattenConnection['recentlyCreatedItems'];
    final recentlyCreatedItems =
        recentlyCreatedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(recentlyCreatedItems, pageInfo);
  }

  Future<Tuple2<List<Item>, PageInfo>> recentlyEditedItems(
      {String? after, bool cache = true}) async {
    final options = QueryOptions(
      document: gql(recentlyEditedItemsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['recentlyEditedItems']['pageInfo']);

    final List<dynamic> recentlyEditedItemsJson =
        results.data!.flattenConnection['recentlyEditedItems'];
    final recentlyEditedItems =
        recentlyEditedItemsJson.map((dynamic e) => Item.fromJson(e)).toList();

    return Tuple2(recentlyEditedItems, pageInfo);
  }

  Future<void> restoreItem({String? itemId}) async {
    final options = MutationOptions(
      document: gql(restoreItemMutation),
      variables: {
        'input': {
          'itemId': itemId,
        },
      },
    );
    await graphqlApiClient.mutate(options);
  }

  Future<Tuple2<List<Storage>, PageInfo>> rootStorage({
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(rootStorageQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo =
        PageInfo.fromJson(results.data!['rootStorage']['pageInfo']);

    final List<dynamic> storagesJson =
        results.data!.flattenConnection['rootStorage'];
    final storages =
        storagesJson.map((dynamic e) => Storage.fromJson(e)).toList();

    return Tuple2(storages, pageInfo);
  }

  Future<Tuple2<List<Item>, List<Storage>>> search(String key,
      {bool isDeleted = false}) async {
    final options = QueryOptions(
      document: gql(searchQuery),
      variables: {
        'key': key,
        'isDeleted': isDeleted,
      },
      fetchPolicy: FetchPolicy.noCache,
    );
    final results = await graphqlApiClient.query(options);

    final json = results.data!.flattenConnection;

    final List<dynamic> storageNameJson = json['storageName'];
    final List<dynamic> storageDescriptionJson = json['storageDescription'];
    final List<dynamic> itemNameJson = json['itemName'];
    final List<dynamic> itemDescriptionJson = json['itemDescription'];

    final storagesName =
        storageNameJson.map((dynamic e) => Storage.fromJson(e)).toList();
    final storagesDescription =
        storageDescriptionJson.map((dynamic e) => Storage.fromJson(e)).toList();
    final itemsName =
        itemNameJson.map((dynamic e) => Item.fromJson(e)).toList();
    final itemsDescription =
        itemDescriptionJson.map((dynamic e) => Item.fromJson(e)).toList();

    // 去重
    final storages = (storagesName + storagesDescription).toSet().toList();
    final items = (itemsName + itemsDescription).toSet().toList();

    return Tuple2(items, storages);
  }

  /// 获取位置详情信息
  ///
  /// stroagePageInfo, itemPageInfo
  Future<Tuple3<Storage, PageInfo, PageInfo>?> storage({
    required String id,
    String? storageCursor,
    String? itemCursor,
    bool cache = true,
  }) async {
    Map<String, dynamic>? storageJson;

    final options = QueryOptions(
      document: gql(storageQuery),
      variables: {
        'id': id,
        'itemCursor': itemCursor,
        'storageCursor': storageCursor,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    storageJson = result.data!['storage'];

    if (storageJson == null) {
      return null;
    }

    // 是否还有下一页
    final storagePageInfo =
        PageInfo.fromJson(storageJson['children']['pageInfo']);
    final itemPageInfo = PageInfo.fromJson(storageJson['items']['pageInfo']);

    // 位置详情
    final json = storageJson.flattenConnection;

    final storage = Storage.fromJson(json);

    return Tuple3(storage, storagePageInfo, itemPageInfo);
  }

  Future<List<Storage>> storages({
    String? key,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(storagesQuery),
      variables: {
        'key': key,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final result = await graphqlApiClient.query(options);

    final List<dynamic> storagesJson =
        result.data!.flattenConnection['storages'];
    final storages =
        storagesJson.map((dynamic e) => Storage.fromJson(e)).toList();

    return storages;
  }

  Future<Item> updateItem({
    required String id,
    String? name,
    int? number,
    String? storageId,
    String? description,
    double? price,
    DateTime? expiredAt,
  }) async {
    final options = MutationOptions(
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

    final Map<String, dynamic> itemJson = result.data!['updateItem'];
    final item = Item.fromJson(itemJson);

    return item;
  }

  Future<Picture> updatePicture({
    required String id,
    required double? boxX,
    required double? boxY,
    required double? boxH,
    required double? boxW,
    String? picturePath,
    String? description,
  }) async {
    MultipartFile? myFile;
    if (picturePath != null) {
      myFile = await _getMultipartFile(picturePath);
    }

    final options = MutationOptions(
      document: gql(updatePictureMutation),
      variables: {
        'input': {
          'id': id,
          'file': myFile,
          'description': description,
          'boxX': boxX,
          'boxY': boxY,
          'boxH': boxH,
          'boxW': boxW,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['updatePicture'];
    final pictureObject = Picture.fromJson(json);
    return pictureObject;
  }

  Future<Storage> updateStorage({
    required String id,
    String? name,
    String? parentId,
    String? description,
  }) async {
    final options = MutationOptions(
      document: gql(updateStorageMutation),
      variables: {
        'input': {
          'id': id,
          'name': name,
          'parentId': parentId,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);

    final Map<String, dynamic> storageJson = result.data!['updateStorage'];
    final storage = Storage.fromJson(storageJson);

    return storage;
  }

  /// 通过 Path 获取 MultipartFile
  Future<MultipartFile> _getMultipartFile(String picturePath) async {
    if (kIsWeb) {
      // 网页需要先下载再转换
      final response = await http.get(Uri.parse(picturePath));
      final mime = lookupMimeType(picturePath, headerBytes: response.bodyBytes)
          ?.split('/');
      return MultipartFile.fromBytes(
        '',
        response.bodyBytes,
        filename: 'picture.${mime?.last}',
        contentType: mime != null ? MediaType(mime.first, mime.last) : null,
      );
    } else {
      final mime = lookupMimeType(picturePath)?.split('/');
      return await MultipartFile.fromPath(
        '',
        picturePath,
        contentType: mime != null ? MediaType(mime.first, mime.last) : null,
      );
    }
  }
}
