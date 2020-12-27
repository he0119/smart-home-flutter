import 'package:meta/meta.dart';
import 'package:smart_home/models/models.dart';

abstract class RoutePath {}

/// 主页相关的信息
class AppRoutePath extends RoutePath {
  final AppTab appTab;

  AppRoutePath({
    this.appTab,
  });

  @override
  String toString() => 'AppRoutePath(appTab: $appTab)';
}

/// 位置相关的信息
class StorageRoutePath extends RoutePath {
  /// 位置名称，空字符串则为 家(/storage/)
  final String storageName;
  final String storageId;

  StorageRoutePath({
    @required this.storageName,
    this.storageId,
  });

  @override
  String toString() => 'StorageRoutePath(storageName: $storageName)';
}

/// 物品相关的信息
class ItemRoutePath extends RoutePath {
  final String itemName;
  final String itemId;

  ItemRoutePath({
    @required this.itemName,
    this.itemId,
  });

  @override
  String toString() => 'ItemRoutePath(itemName: $itemName)';
}

/// 留言板相关的信息
class TopicRoutePath extends RoutePath {
  /// 物品 ID，空则为 家(/storage/home)
  final String topicId;

  TopicRoutePath({
    this.topicId,
  });

  @override
  String toString() => 'TopicRoutePath(topicId: $topicId)';
}
