import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:version/version.dart';

class VersionRepository {
  Version _currentVersion;
  Version _onlineVersion;
  String _deviceAbi;

  Future<Version> get currentVersion async {
    if (_currentVersion == null) {
      _currentVersion = await _getCurrentVersion();
    }
    return _currentVersion;
  }

  Future<String> get deviceAbi async {
    if (_deviceAbi == null) {
      _deviceAbi = await _getDeviceAbi();
    }
    return _deviceAbi;
  }

  Future<Version> get onlineVersion async {
    if (_onlineVersion == null) {
      _onlineVersion = await _getOnlineVersion();
    }
    return _onlineVersion;
  }

  /// 是否需要更新
  Future<bool> needUpdate() async {
    if (await onlineVersion > await currentVersion) {
      return true;
    }
    return false;
  }

  /// 更新文件的下载地址
  Future<String> updateUrl() async {
    return 'https://github.com/he0119/smart-home-flutter/releases/download/v${await onlineVersion}/app-${await deviceAbi}-release.apk';
  }

  /// 当前版本
  Future<Version> _getCurrentVersion() async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    return Version.parse(info.version);
  }

  /// 设备的 ABI
  Future<String> _getDeviceAbi() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    List<String> abis = androidInfo.supportedAbis;
    if (abis.contains('x86_64')) {
      return 'x86_64';
    }
    if (abis.contains('arm64-v8a')) {
      return 'arm64-v8a';
    }
    if (abis.contains('armeabi-v7a')) {
      return 'armeabi-v7a';
    }
    return '';
  }

  /// 网上的版本
  Future<Version> _getOnlineVersion() async {
    var url =
        'https://api.github.com/repos/he0119/smart-home-flutter/releases/latest';
    try {
      var response = await http.get(url);
      Map<String, dynamic> json = jsonDecode(response.body);
      String versionName = json['tag_name'];
      return Version.parse(versionName.replaceAll('v', ''));
    } catch (e) {
      // 如果检查更新失败则直接返回 0.0.0
      // TODO: 处理异常，增加失败提示
      return Version(0, 0, 0);
    }
  }
}
