part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarEvent {}

class SnackBarChanged extends SnackBarEvent {
  final SnackBarPosition position;
  final String message;
  final MessageType type;

  SnackBarChanged({
    @required this.position,
    @required this.message,
    @required this.type,
  });

  @override
  String toString() =>
      'SnackBarChanged { message: $message }';
}
