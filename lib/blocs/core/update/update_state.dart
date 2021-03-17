part of 'update_bloc.dart';

@immutable
abstract class UpdateState {}

class UpdateInitial extends UpdateState {
  @override
  String toString() => 'UpdateInitial';
}

class UpdateFailure extends UpdateState {
  final String? message;

  UpdateFailure(this.message);

  @override
  String toString() => 'UpdateFailure { message: $message }';
}

class UpdateSuccess extends UpdateState {
  final bool needUpdate;
  final String? url;
  final Version? version;

  UpdateSuccess({required this.needUpdate, this.url, this.version});

  @override
  String toString() =>
      'UpdateSuccess { needUpdate: $needUpdate, version: $version }';
}
