/// 异常
class MyException implements Exception {
  final String message;

  const MyException(this.message);
}

/// 认证异常
class AuthenticationException extends MyException {
  const AuthenticationException(String message) : super(message);
}

/// 服务器异常
class ServerException extends MyException {
  const ServerException(String message) : super(message);
}

/// 网络异常
class NetworkException extends MyException {
  const NetworkException(String message) : super(message);
}
