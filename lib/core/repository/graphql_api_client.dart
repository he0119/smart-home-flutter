import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' hide NetworkException, ServerException;
import 'package:http/http.dart' hide Response, Request;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/graphql/mutations/mutations.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/user/repository/user_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

class ClientWithCookies extends IOClient {
  final SettingsController settingsController;

  ClientWithCookies(this.settingsController) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    final cookie = settingsController.cookies;
    if (cookie != null) {
      request.headers['cookie'] = cookie;
    }
    return super.send(request).then((response) {
      final cookiesString = response.headers['set-cookie'];
      final request = response.request;
      if (cookiesString != null && request != null) {
        // 这个分割真的难受，不知道还没有更好的方法
        // cookie 有效期的格式中包含了逗号
        final cookieStringList = cookiesString.split(',');
        List<Cookie> cookies = [];
        for (var i = 0; i < cookieStringList.length; i += 2) {
          cookies.add(Cookie.fromSetCookieValue(
              cookieStringList[i] + cookieStringList[i + 1]));
        }
        final newCookies =
            cookies.map((e) => '${e.name}=${e.value}').join('; ');
        settingsController.updateCookies(newCookies);
      }
      return response;
    });
  }
}

/// 强行加上 OperationInfo
class AddOperationInfoVisitor extends TransformingVisitor {
  @override
  SelectionSetNode visitSelectionSetNode(SelectionSetNode node) {
    final hasInlineFragment =
        node.selections.whereType<InlineFragmentNode>().isNotEmpty;

    if (!hasInlineFragment) return node;

    final hasOperation = node.selections
        .whereType<InlineFragmentNode>()
        .any((node) => node.typeCondition?.on.name.value == 'OperationInfo');

    if (hasOperation) return node;

    return SelectionSetNode(
      selections: [
        ...node.selections,
        const InlineFragmentNode(
          typeCondition: TypeConditionNode(
            on: NamedTypeNode(
              name: NameNode(
                value: 'OperationInfo',
              ),
            ),
          ),
          selectionSet: SelectionSetNode(
            selections: [
              FieldNode(
                name: NameNode(value: '__typename'),
              ),
              FieldNode(
                name: NameNode(value: 'messages'),
                selectionSet: SelectionSetNode(
                  selections: [
                    FieldNode(
                      name: NameNode(value: '__typename'),
                    ),
                    FieldNode(
                      name: NameNode(value: 'message'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

/// 给 Mutation 强行加上 OperationInfo
DocumentNode opi(DocumentNode document) => transform(
      document,
      [AddOperationInfoVisitor()],
    );

class SocketCustomLink extends Link {
  SocketCustomLink(
    this.url,
    this.defaultHeaders,
    this.settingsController,
    this.onConnectionLost,
    this.connectionStateController,
  );
  final String url;
  final Map<String, String> defaultHeaders;
  final SettingsController settingsController;
  final Future<Duration?> Function(int? code, String? reason) onConnectionLost;
  final StreamController<bool> connectionStateController;

  _Connection? _connection;

  /// this will be called every time you make a subscription
  @override
  Stream<Response> request(Request request, [forward]) async* {
    /// first get the token by your own way
    String? cookies = settingsController.cookies;

    /// check is connection is null or the token changed
    if (_connection == null || _connection!.cookies != cookies) {
      connectOrReconnect(cookies);
    }
    yield* _connection!.client.subscribe(request, true);
  }

  /// Connects or reconnects to the server with the specified headers.
  void connectOrReconnect(String? cookies) {
    _connection?.client.dispose();
    _connection = _Connection(
      client: SocketClient(
        url,
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: const Duration(hours: 1),
          headers: kIsWeb || cookies == null
              ? null
              : {'cookie': cookies, ...defaultHeaders},
          onConnectionLost: onConnectionLost,
        ),
      ),
      cookies: cookies,
    );

    // 监听连接状态
    _connection?.client.connectionState.listen((event) {
      if (event == SocketConnectionState.connected) {
        connectionStateController.add(true);
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _connection?.client.dispose();
    _connection = null;
  }
}

/// this a wrapper for web socket to hold the used token
class _Connection {
  SocketClient client;
  String? cookies;
  _Connection({
    required this.client,
    required this.cookies,
  });
}

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static Map<String, String> headers = {};
  static GraphQLClient? _client;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SettingsController settingsController;

  final StreamController<bool> _websocketConnectionStateController =
      StreamController<bool>.broadcast();

  GraphQLApiClient(this.settingsController);

  GraphQLClient? get client => _client;

  Future<String?> get token async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  Stream<bool> get websocketConnectionState =>
      _websocketConnectionStateController.stream;

  /// 登录
  Future<User?> login(String username, String password) async {
    final loginOptions = MutationOptions(
      document: gql(loginMutation),
      variables: {
        'input': {
          'username': username,
          'password': password,
        }
      },
    );
    final results = await _client!.mutate(loginOptions);

    if (!results.hasException) {
      final data = results.data!['login'];
      if (data['__typename'] == 'User') {
        final user = User.fromJson(data);
        return user;
      }
    } else {
      if (results.exception!.linkException != null) {
        throw const NetworkException('网络异常，请稍后再试');
      }
    }
    return null;
  }

  /// OIDC 单点登录
  ///
  /// 返回登录后的用户信息
  Future<User?> oidcLogin() async {
    if (settingsController.apiUrl == null) {
      throw const NetworkException('请先设置服务器地址');
    }

    // 从 apiUrl 中移除 /graphql/ 路径，构建 OIDC 端点
    // apiUrl 格式: https://smart.dev.hehome.xyz/graphql/
    // oidcUrl 格式: https://smart.dev.hehome.xyz/oidc/authenticate/
    var baseUrl = settingsController.apiUrl!;
    if (baseUrl.endsWith('/graphql/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 9); // 移除 '/graphql/'
    } else if (baseUrl.endsWith('/graphql')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 8); // 移除 '/graphql'
    } else if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1); // 移除尾部 '/'
    }
    final oidcUrl = '$baseUrl/oidc/authenticate/';

    try {
      // 创建一个不自动跟随重定向的 HTTP 客户端
      final httpClient = HttpClient();

      // 手动跟随重定向
      String currentUrl = oidcUrl;
      Map<String, String> currentHeaders = Map.from(headers);
      List<Cookie> allCookies = [];
      int redirectCount = 0;
      const maxRedirects = 20; // 最大重定向次数，防止无限循环

      _log.info('开始 OIDC 认证: $currentUrl');

      while (redirectCount < maxRedirects) {
        final request = await httpClient.getUrl(Uri.parse(currentUrl));
        request.followRedirects = false; // 禁用自动重定向

        // 添加请求头
        currentHeaders.forEach((key, value) {
          request.headers.set(key, value);
        });

        final httpResponse = await request.close();
        final statusCode = httpResponse.statusCode;

        _log.info('步骤 ${redirectCount + 1}: 状态码 $statusCode, URL: $currentUrl');

        // 收集 cookies
        final setCookieHeaders = httpResponse.headers['set-cookie'];
        if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
          for (var cookieString in setCookieHeaders) {
            try {
              allCookies.add(Cookie.fromSetCookieValue(cookieString));
            } catch (e) {
              _log.warning('解析 cookie 失败: $cookieString');
            }
          }
          _log.info('收集到 ${allCookies.length} 个 cookies');
        }

        // 检查是否是重定向响应
        if (statusCode == 302 ||
            statusCode == 301 ||
            statusCode == 303 ||
            statusCode == 307 ||
            statusCode == 308) {
          final locationHeaders = httpResponse.headers['location'];
          if (locationHeaders == null || locationHeaders.isEmpty) {
            _log.warning('重定向响应但未找到 location 头');
            break;
          }

          final location = locationHeaders.first;

          // 处理相对路径和绝对路径
          final locationUri = Uri.parse(location);
          if (locationUri.isAbsolute) {
            currentUrl = location;
          } else {
            final currentUri = Uri.parse(currentUrl);
            currentUrl = currentUri.resolve(location).toString();
          }

          // 检查是否已经到达 admin 页面
          if (currentUrl.contains('/admin')) {
            _log.info('已到达 admin 页面，认证成功: $currentUrl');
            break;
          }

          // 更新请求头，添加已收集的 cookies
          if (allCookies.isNotEmpty) {
            currentHeaders['cookie'] =
                allCookies.map((e) => '${e.name}=${e.value}').join('; ');
          }

          redirectCount++;
          _log.info('跟随重定向到: $currentUrl');
        } else if (statusCode == 200) {
          // 检查 URL 是否包含 admin
          if (currentUrl.contains('/admin')) {
            _log.info('成功到达 admin 页面: $currentUrl');
            break;
          } else {
            _log.warning('收到 200 响应但不在 admin 页面: $currentUrl');
            break;
          }
        } else {
          _log.warning('收到非预期的状态码: $statusCode');
          break;
        }
      }

      if (redirectCount >= maxRedirects) {
        _log.warning('达到最大重定向次数限制');
        throw const NetworkException('OIDC 认证失败：重定向次数过多');
      }

      if (allCookies.isEmpty) {
        _log.warning('未获取到任何 cookies');
        throw const NetworkException('OIDC 认证失败：未获取到认证信息');
      }

      // 保存所有收集到的 cookies
      final newCookies =
          allCookies.map((e) => '${e.name}=${e.value}').join('; ');
      _log.info('成功获取 cookies: $newCookies');
      await settingsController.updateCookies(newCookies);

      // 关闭 HTTP 客户端
      httpClient.close();

      // 获取当前用户信息
      final userRepository = UserRepository(graphqlApiClient: this);
      final user = await userRepository.currentUser();
      _log.info('成功获取用户信息: ${user.username}');
      return user;
    } catch (e) {
      _log.severe('OIDC 登录失败: $e');
      if (e is MyException) {
        rethrow;
      }
      throw const NetworkException('OIDC 登录失败，请稍后再试');
    }
  }

  Future<bool> logout() async {
    final loginOptions = MutationOptions(
      document: opi(gql(logoutMutation)),
    );
    final results = await mutate(loginOptions);
    if (results.hasException) {
      if (results.exception!.linkException != null) {
        throw const NetworkException('网络异常，请稍后再试');
      }
      return false;
    } else {
      return true;
    }
  }

  /// 初始化 GraphQL 客户端
  void initailize(String url) {
    Link link;
    if (!kIsWeb) {
      link = HttpLink(
        url,
        httpClient: ClientWithCookies(settingsController),
        defaultHeaders: headers,
      );
    } else {
      link = HttpLink(
        url,
        defaultHeaders: headers,
      );
    }
    final websocketLink = SocketCustomLink(
      url.replaceFirst('http', 'ws'),
      headers,
      settingsController,
      onWebsocketConnectionLost,
      _websocketConnectionStateController,
    );

    link = Link.split((request) => request.isSubscription, websocketLink, link);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
    _log.fine('GraphQLClient initailized with url $url');
    websocketConnectionState.listen((event) {
      if (event) {
        _log.info('Websocket connected');
      } else {
        _log.warning('Websocket disconnected');
      }
    });
  }

  /// 加载配置，比如用户代理
  /// 这些需要在最开始就加载，因为后面的操作需要用到
  Future<void> loadSettings() async {
    if (kIsWeb) return;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      // 用户代理设置为当前手机
      // 支持 Android 和 Windows
      // SmartHome/0.6.1 (Linux; Android 10; Mi-4c Build/QQ3A.200805.001)
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        headers['User-Agent'] =
            'SmartHome/${packageInfo.version} (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id})';
      }
      // SmartHome/0.9.0 (Windows NT; Build/22621.ni_release.220506-1250) HMY-SPIN5
      else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        headers['User-Agent'] =
            'SmartHome/${packageInfo.version} (Windows NT; Build/${windowsInfo.buildLab}) ${windowsInfo.computerName}';
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      _log.severe('设置 User-Agent 失败 ($exception)');
    }
  }

  /// 更改
  Future<QueryResult> mutate(MutationOptions options) async {
    final results = await _client!.mutate(options);
    if (results.hasException) {
      _handleException(results.exception!);
    }
    // 一些简化的操作
    // 暂时先这样吧，如果 Mutation 出错的话，会返回 OperationInfo
    if (options.document.definitions.first is OperationDefinitionNode) {
      final nodeName =
          (options.document.definitions.first as OperationDefinitionNode)
              .name!
              .value;
      final data = results.data![nodeName];

      if (data['__typename'] == 'OperationInfo') {
        try {
          final String errorMessage = data['messages'][0]['message'];
          throw ServerException(errorMessage);
        } on NoSuchMethodError {
          throw const NetworkException('操作失败，请稍后再试');
        }
      }
    }
    return results;
  }

  /// 查询
  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client!.query(options);
    if (results.hasException) {
      _handleException(results.exception!);
    }
    return results;
  }

  /// 订阅
  Stream<QueryResult> subscribe(SubscriptionOptions options) {
    return _client!.subscribe(options).map((event) {
      if (event.hasException) {
        _handleException(event.exception!);
      }
      return event;
    });
  }

  /// 处理异常
  void _handleException(OperationException exception) {
    for (var error in exception.graphqlErrors) {
      if (error.message == 'User is not authenticated') {
        settingsController.updateLoginUser(null);
        throw const AuthenticationException('认证过期，请重新登录');
      }
      _log.warning(error.toString());
      throw ServerException(error.message);
    }
    if (exception.linkException != null) {
      _log.severe(exception.linkException.toString());
      throw const NetworkException('网络异常，请稍后再试');
    }
  }

  Future<Duration?> onWebsocketConnectionLost(int? code, String? reason) async {
    _log.warning(
        'Websocket Connection lost with code $code and reason $reason');
    _websocketConnectionStateController.add(false);
    return null;
  }
}
