part of 'update_bloc.dart';

@immutable
abstract class UpdateEvent {}

class UpdateStarted extends UpdateEvent {
  @override
  String toString() => 'UpdateStarted';
}
