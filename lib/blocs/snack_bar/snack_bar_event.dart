part of 'snack_bar_bloc.dart';

abstract class SnackBarEvent extends Equatable {
  const SnackBarEvent();

  @override
  List<Object> get props => [];
}

class SnackBarChanged extends SnackBarEvent {
  final String message;
  final MessageType messageType;

  const SnackBarChanged({
    @required this.message,
    @required this.messageType,
  });

  @override
  List<Object> get props => [message, messageType];
}
