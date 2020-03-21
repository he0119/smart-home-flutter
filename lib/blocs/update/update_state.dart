part of 'update_bloc.dart';

@immutable
abstract class UpdateState {}

class UpdateInitial extends UpdateState {
  @override
  String toString() => 'UpdateInitial';
}

class UpdateSuccess extends UpdateState {
  final bool needUpdate;
  final String url;
  final Version version;

  UpdateSuccess({this.needUpdate, this.url, this.version});

  @override
  String toString() =>
      'UpdateSuccess { needUpdate: $needUpdate, version: $version }';
}
