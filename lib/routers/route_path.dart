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

/// 物品管理相关的信息
class StorageRoutePath extends RoutePath {
  /// 物品 ID，空则为 家(/storage/home)
  final String storageId;

  StorageRoutePath({
    this.storageId,
  });

  @override
  String toString() => 'StorageRoutePath(storageId: $storageId)';
}
