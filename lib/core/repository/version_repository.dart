import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:version/version.dart';

class VersionRepository {
  static final Logger _log = Logger('VersionRepository');
  Version? _currentVersion;
  Version? _onlineVersion;
  String? _deviceAbi;
  bool _fileExist = false;
  String? _downloadUrl;
  String? _changelog;

  Future<Version> get currentVersion async {
    _currentVersion ??= await _getCurrentVersion();
    return _currentVersion!;
  }

  Future<String> get deviceAbi async {
    _deviceAbi ??= await _getDeviceAbi();
    return _deviceAbi!;
  }

  Future<Version> get onlineVersion async {
    _onlineVersion ??= await _getOnlineVersion();
    return _onlineVersion!;
  }

  /// 是否需要更新
  Future<bool> needUpdate() async {
    final current = await currentVersion;

    // 如果是从 Git 编译的开发版，则不用检查更新
    if (current.preRelease.isNotEmpty && current.preRelease.first == 'git') {
      return false;
    }

    if (await onlineVersion > current && _fileExist) {
      return true;
    }
    return false;
  }

  Future<String> get filename async =>
      'app-prod-${await deviceAbi}-release.apk';

  String? get changelog => _changelog;

  /// 更新文件的下载地址
  Future<String> updateUrl() async {
    if (_downloadUrl != null) {
      return _downloadUrl!;
    }
    return 'https://github.com/he0119/smart-home-flutter/releases/download/v${await onlineVersion}/${await filename}';
  }

  /// 当前版本
  Future<Version> _getCurrentVersion() async {
    //Get Current installed version of app
    final info = await PackageInfo.fromPlatform();
    return Version.parse(info.version);
  }

  /// 设备的 ABI
  Future<String> _getDeviceAbi() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final abis = androidInfo.supportedAbis;
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
  /// 通过 GitHub Releases API 获取最新的版本号
  Future<Version> _getOnlineVersion() async {
    const url =
        'https://api.github.com/repos/he0119/smart-home-flutter/releases';
    try {
      final response = await http.get(Uri.parse(url));
      final List<dynamic> releases = jsonDecode(response.body);
      if (releases.isEmpty) {
        throw const NetworkException('检查更新失败，请重试');
      }
      final latest = releases.first;
      final tagName = latest['tag_name'] as String;
      _changelog = latest['body'] as String?;
      final versionStr = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      final assets = latest['assets'] as List<dynamic>;
      final targetFilename = await filename;
      _fileExist = false;
      for (final asset in assets) {
        if (asset['name'] == targetFilename) {
          _downloadUrl = asset['browser_download_url'];
          _fileExist = true;
          break;
        }
      }

      _log.fine('最新的版本号为 { $versionStr }');
      return Version.parse(versionStr);
    } catch (e) {
      _log.warning(e);
      throw const NetworkException('检查更新失败，请重试');
    }
  }
}
