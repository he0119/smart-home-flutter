import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class VersionRepository {
  static final Logger _log = Logger('VersionRepository');
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
    return 'https://hub.fastgit.org/he0119/smart-home-flutter/releases/download/v${await onlineVersion}/app-${await deviceAbi}-release.apk';
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
  /// 通过 GitHub Releases 页面获取最新的版本号
  Future<Version> _getOnlineVersion() async {
    final RegExp _versionRegex = RegExp(
        r'releases/tag/v([\d.]+)(-([0-9A-Za-z\-.]+))?(\+([0-9A-Za-z\-.]+))?');
    final String url =
        'https://hub.fastgit.org/he0119/smart-home-flutter/releases/latest';
    try {
      var response = await http.get(url);
      final Match match = _versionRegex.firstMatch(response.body);
      if (match == null) {
        throw Exception('检查更新失败，请重试');
      } else {
        String versionName = match.group(1);
        _log.fine('最新的版本号字符 { $versionName }');
        return Version.parse(versionName);
      }
    } catch (e) {
      _log.warning(e);
      throw Exception('检查更新失败，请重试');
    }
  }
}
