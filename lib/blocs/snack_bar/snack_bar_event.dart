part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarEvent {}

class SnackBarChanged extends SnackBarEvent {
  final String message;
  final MessageType messageType;

  SnackBarChanged({
    @required this.message,
    @required this.messageType,
  });

  @override
  String toString() => 'SnackBarChanged { message: $message }';
}
