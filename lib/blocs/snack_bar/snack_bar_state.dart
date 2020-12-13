part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarState {}

class SnackBarInitial extends SnackBarState {}

class SnackBarSuccess extends SnackBarState {
  final String message;
  final MessageType type;
  final int duration;

  SnackBarSuccess({
    @required this.message,
    @required this.type,
    @required this.duration,
  });

  @override
  String toString() => 'SnackBarSuccess { messageType: $type }';
}
