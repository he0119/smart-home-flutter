part of 'snack_bar_bloc.dart';

abstract class SnackBarState extends Equatable {
  const SnackBarState();

  @override
  List<Object> get props => [];
}

class SnackBarInitial extends SnackBarState {}

class SnackBarSuccess extends SnackBarState {
  final String message;
  final MessageType messageType;

  const SnackBarSuccess({
    @required this.message,
    @required this.messageType,
  });

  @override
  List<Object> get props => [message, messageType];
}
