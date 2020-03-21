part of 'update_bloc.dart';

@immutable
abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateSuccess extends UpdateState {
  final bool needUpdate;
  final String url;

  UpdateSuccess({this.needUpdate, this.url});

  @override
  String toString() => 'UpdateSuccess { needUpdate: $needUpdate }';
}
