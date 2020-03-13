part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarState {}

class SnackBarInitial extends SnackBarState {}

class SnackBarSuccess extends SnackBarState {
  final String message;
  final MessageType messageType;

  SnackBarSuccess({
    @required this.message,
    @required this.messageType,
  });

  @override
  String toString() => 'SnackBarSuccess { messageType: $messageType }';
}
