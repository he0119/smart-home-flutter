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
  SocketCustomLink(this.url, this.settingsController);
  final String url;
  _Connection? _connection;
  final SettingsController settingsController;

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
          headers: kIsWeb || cookies == null ? null : {'cookie': cookies},
        ),
      ),
      cookies: cookies,
    );
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

  GraphQLApiClient(
    this.settingsController,
  );

  GraphQLClient? get client => _client;

  Future<String?> get token async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  /// 登录
  Future<User?> authenticate(String username, String password) async {
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
    if (results.hasException) {
      if (results.exception!.linkException != null) {
        throw const NetworkException('网络异常，请稍后再试');
      }
      return null;
    } else {
      final data = results.data!['login'];
      if (data['__typename'] == 'User') {
        final user = User.fromJson(data);
        return user;
      }
    }
    return null;
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
    final websocketLink =
        SocketCustomLink(url.replaceFirst('http', 'ws'), settingsController);

    link = Link.split((request) => request.isSubscription, websocketLink, link);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
    _log.fine('GraphQLClient initailized with url $url');
  }

  /// 加载配置，比如用户代理
  /// 这些需要在最开始就加载，因为后面的操作需要用到
  Future<void> loadSettings() async {
    // 用户代理设置为当前手机
    // 暂时只支持 Android
    // SmartHome/0.6.1 (Linux; Android 10; Mi-4c Build/QQ3A.200805.001)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final packageInfo = await PackageInfo.fromPlatform();
        headers['User-Agent'] =
            'SmartHome/${packageInfo.version} (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id})';
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        _log.severe('设置 User-Agent 失败 (${exception.toString()})');
      }
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
    if (options.document.definitions.first.runtimeType.toString() ==
        'OperationDefinitionNode') {
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

  Stream<QueryResult> subscribe(SubscriptionOptions options) {
    return _client!.subscribe(options);
  }

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
}
