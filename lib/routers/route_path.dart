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
