import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' hide NetworkException, ServerException;
import 'package:http/http.dart' hide Response, Request;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/graphql/mutations/mutations.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/user/repository/user_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

class ClientWithCookies extends IOClient {
  final Ref ref;

  ClientWithCookies(this.ref) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    final cookie = ref.read(settingsProvider).cookies;
    if (cookie != null) {
      request.headers['cookie'] = cookie;
    }
    return super.send(request).then((response) {
      final cookiesString = response.headers['set-cookie'];
      final request = response.request;
      if (cookiesString != null && request != null) {
        // 解析 Set-Cookie 头
        // Set-Cookie 头可能包含多个 cookie，使用更可靠的方式解析
        final List<Cookie> cookies = [];

        // 使用正则表达式匹配完整的 cookie 字符串
        // 匹配模式：cookie_name=cookie_value; 后面可能跟其他属性
        final cookiePattern = RegExp(
          r'([^=,]+)=([^;]+)(?:;\s*[^,]+(?:,\s*\d{2}\s+[A-Za-z]+\s+\d{4}\s+[\d:]+\s+GMT)?)*',
        );

        final matches = cookiePattern.allMatches(cookiesString);
        for (final match in matches) {
          try {
            // 尝试解析整个 cookie 字符串
            final cookieStr = match.group(0);
            if (cookieStr != null) {
              final cookie = Cookie.fromSetCookieValue(cookieStr);
              cookies.add(cookie);
            }
          } catch (e) {
            // 如果解析失败，跳过这个 cookie
            continue;
          }
        }

        if (cookies.isNotEmpty) {
          final newCookies = cookies
              .map((e) => '${e.name}=${e.value}')
              .join('; ');
          ref.read(settingsProvider.notifier).updateCookies(newCookies);
        }
      }
      return response;
    });
  }
}

/// 强行加上 OperationInfo
class AddOperationInfoVisitor extends TransformingVisitor {
  @override
  SelectionSetNode visitSelectionSetNode(SelectionSetNode node) {
    final hasInlineFragment = node.selections
        .whereType<InlineFragmentNode>()
        .isNotEmpty;

    if (!hasInlineFragment) return node;

    final hasOperation = node.selections.whereType<InlineFragmentNode>().any(
      (node) => node.typeCondition?.on.name.value == 'OperationInfo',
    );

    if (hasOperation) return node;

    return SelectionSetNode(
      selections: [
        ...node.selections,
        const InlineFragmentNode(
          typeCondition: TypeConditionNode(
            on: NamedTypeNode(name: NameNode(value: 'OperationInfo')),
          ),
          selectionSet: SelectionSetNode(
            selections: [
              FieldNode(name: NameNode(value: '__typename')),
              FieldNode(
                name: NameNode(value: 'messages'),
                selectionSet: SelectionSetNode(
                  selections: [
                    FieldNode(name: NameNode(value: '__typename')),
                    FieldNode(name: NameNode(value: 'message')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 给 Mutation 强行加上 OperationInfo
DocumentNode opi(DocumentNode document) =>
    transform(document, [AddOperationInfoVisitor()]);

class SocketCustomLink extends Link {
  SocketCustomLink(
    this.url,
    this.defaultHeaders,
    this.ref,
    this.onConnectionLost,
    this.connectionStateController,
  );
  final String url;
  final Map<String, String> defaultHeaders;
  final Ref ref;
  final Future<Duration?> Function(int? code, String? reason) onConnectionLost;
  final StreamController<bool> connectionStateController;

  _Connection? _connection;

  /// this will be called every time you make a subscription
  @override
  Stream<Response> request(Request request, [forward]) async* {
    /// first get the token by your own way
    String? cookies = ref.read(settingsProvider).cookies;

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
  _Connection({required this.client, required this.cookies});
}

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static Map<String, String> headers = {};
  static GraphQLClient? _client;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final Ref ref;

  final StreamController<bool> _websocketConnectionStateController =
      StreamController<bool>.broadcast();

  GraphQLApiClient(this.ref);

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
        'input': {'username': username, 'password': password},
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
    final apiUrl = ref.read(settingsProvider).apiUrl;
    if (apiUrl == null) {
      throw const NetworkException('请先设置服务器地址');
    }

    // 构建 OIDC 端点 URL
    final baseUri = Uri.parse(apiUrl);
    final oidcUri = baseUri.replace(path: '/oidc/authenticate/');

    try {
      _log.info('开始 OIDC 认证: $oidcUri');

      // 使用 HttpClient 手动处理重定向以收集所有 cookies
      final httpClient = HttpClient();

      final allCookies = <Cookie>[];
      var currentUri = oidcUri;
      var redirectCount = 0;
      const maxRedirects = 20;

      while (redirectCount < maxRedirects) {
        final request = await httpClient.getUrl(currentUri);
        request.followRedirects = false; // 禁用自动重定向

        // 添加请求头
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });

        // 添加已收集的 cookies
        if (allCookies.isNotEmpty) {
          request.headers.set(
            'cookie',
            allCookies.map((e) => '${e.name}=${e.value}').join('; '),
          );
        }

        final response = await request.close();
        _log.info(
          '步骤 ${redirectCount + 1}: 状态码 ${response.statusCode}, URL: $currentUri',
        );

        // 收集 cookies
        final setCookies = response.cookies;
        if (setCookies.isNotEmpty) {
          allCookies.addAll(setCookies);
          _log.info('收集到 ${allCookies.length} 个 cookies');
        }

        // 处理重定向
        if (response.isRedirect) {
          final location = response.headers.value('location');
          if (location == null) {
            _log.warning('重定向响应但未找到 location 头');
            break;
          }

          currentUri = currentUri.resolve(location);
          _log.info('跟随重定向到: $currentUri');

          // 检查是否已到达 admin 页面
          if (currentUri.path.contains('/admin')) {
            _log.info('已到达 admin 页面,认证成功: $currentUri');
            break;
          }

          redirectCount++;
        } else if (response.statusCode == 200) {
          if (currentUri.path.contains('/admin')) {
            _log.info('成功到达 admin 页面: $currentUri');
          } else {
            _log.warning('收到 200 响应但不在 admin 页面: $currentUri');
          }
          break;
        } else {
          _log.warning('收到非预期的状态码: ${response.statusCode}');
          break;
        }
      }

      httpClient.close();

      if (redirectCount >= maxRedirects) {
        _log.warning('达到最大重定向次数限制');
        throw const NetworkException('OIDC 认证失败：重定向次数过多');
      }

      if (allCookies.isEmpty) {
        _log.warning('未获取到任何 cookies');
        throw const NetworkException('OIDC 认证失败：未获取到认证信息');
      }

      // 保存所有收集到的 cookies
      final cookiesString = allCookies
          .map((e) => '${e.name}=${e.value}')
          .join('; ');
      _log.info('成功获取 cookies: $cookiesString');
      await ref.read(settingsProvider.notifier).updateCookies(cookiesString);

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
      throw const NetworkException('OIDC 登录失败,请稍后再试');
    }
  }

  Future<bool> logout() async {
    final loginOptions = MutationOptions(document: opi(gql(logoutMutation)));
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
        httpClient: ClientWithCookies(ref),
        defaultHeaders: headers,
      );
    } else {
      link = HttpLink(url, defaultHeaders: headers);
    }
    final websocketLink = SocketCustomLink(
      url.replaceFirst('http', 'ws'),
      headers,
      ref,
      onWebsocketConnectionLost,
      _websocketConnectionStateController,
    );

    link = Link.split((request) => request.isSubscription, websocketLink, link);

    _client = GraphQLClient(cache: GraphQLCache(), link: link);
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
      await Sentry.captureException(exception, stackTrace: stackTrace);
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
        ref.read(settingsProvider.notifier).updateLoginUser(null);
        throw const AuthenticationException('认证过期，请重新登录');
      }
      _log.warning(error.toString());
      throw ServerException(error.message);
    }
    if (exception.linkException != null) {
      if (exception.linkException.toString().contains('Invalid cookie')) {
        ref.read(settingsProvider.notifier).updateLoginUser(null);
        throw const AuthenticationException('Cookie 无效，请重新登录');
      }
      _log.severe(exception.linkException.toString());
      throw const NetworkException('网络异常，请稍后再试');
    }
  }

  Future<Duration?> onWebsocketConnectionLost(int? code, String? reason) async {
    _log.warning(
      'Websocket Connection lost with code $code and reason $reason',
    );
    _websocketConnectionStateController.add(false);
    return null;
  }
}
