part of 'snack_bar_bloc.dart';

@immutable
abstract class SnackBarState {}

class SnackBarInitial extends SnackBarState {}

class SnackBarSuccess extends SnackBarState {
  final SnackBarPosition position;
  final String message;
  final MessageType type;

  SnackBarSuccess({
    @required this.position,
    @required this.message,
    @required this.type,
  });

  @override
  String toString() =>
      'SnackBarSuccess { position: $position, messageType: $type }';
}
