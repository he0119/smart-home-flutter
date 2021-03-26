/// 异常
class MyException implements Exception {
  final String message;

  const MyException(this.message);
}

/// 认证异常
class AuthenticationException extends MyException {
  final String message;

  const AuthenticationException(this.message) : super(message);
}

/// 服务器异常
class ServerException extends MyException {
  final String message;

  const ServerException(this.message) : super(message);
}

/// 网络异常
class NetworkException extends MyException {
  final String message;

  const NetworkException(this.message) : super(message);
}
