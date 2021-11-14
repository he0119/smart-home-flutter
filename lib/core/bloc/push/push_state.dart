part of 'push_bloc.dart';

abstract class PushState extends Equatable {
  const PushState();

  @override
  List<Object> get props => [];
}

class PushInProgress extends PushState {
  @override
  String toString() => 'PushInProgress';
}

class PushSuccess extends PushState {
  /// 本地获取的推送 RegId
  final String local;

  /// 服务器上的推送 RegId
  final String server;

  const PushSuccess({
    required this.local,
    required this.server,
  });

  @override
  List<Object> get props => [local, server];

  @override
  String toString() => 'PushSuccess(local: $local, server: $server)';

  PushSuccess copyWith({
    String? local,
    String? server,
  }) {
    return PushSuccess(
      local: local ?? this.local,
      server: server ?? this.server,
    );
  }
}

/// 网络错误
class PushError extends PushState {
  final String message;

  const PushError(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'PushError(message: $message)';
}
