import 'package:meta/meta.dart';
import 'package:smarthome/models/models.dart';

abstract class RoutePath {}

/// 主页相关的信息
class HomeRoutePath extends RoutePath {
  /// 主页
  ///
  /// 空则为默认主页
  final AppTab appTab;

  HomeRoutePath({
    this.appTab,
  });

  @override
  String toString() => 'HomeRoutePath(appTab: $appTab)';
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

/// 图片相关的信息
class PictureRoutePath extends RoutePath {
  /// 图片的 ID
  final String pictureId;

  PictureRoutePath({
    @required this.pictureId,
  });

  @override
  String toString() => 'PictureRoutePath(pictureId: $pictureId)';
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

/// 应用相关的信息
///
/// 一些独立页面
class AppRoutePath extends RoutePath {
  final AppPage appPage;

  AppRoutePath(this.appPage);

  @override
  String toString() => 'AppRoutePath(appPage: $appPage)';
}

/// 主页相关的信息
class SettingsRoutePath extends RoutePath {
  /// 主页
  ///
  /// 空则为默认主页
  final AppSettings appSettings;

  SettingsRoutePath({
    this.appSettings,
  });

  @override
  String toString() => 'SettingsRoutePath(appTab: $appSettings)';
}
