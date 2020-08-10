part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarEvent {}

class SnackBarChanged extends SnackBarEvent {
  final SnackBarPosition position;
  final String message;
  final MessageType type;
  final int duration;

  SnackBarChanged({
    @required this.position,
    @required this.message,
    @required this.type,
    this.duration = 4,
  });

  @override
  String toString() => 'SnackBarChanged { message: $message }';
}
