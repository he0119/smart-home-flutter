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
  final MiPush miPush;

  const PushSuccess({required this.miPush});

  @override
  List<Object> get props => [miPush];

  @override
  String toString() => 'PushSuccess(miPush: $miPush)';
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
