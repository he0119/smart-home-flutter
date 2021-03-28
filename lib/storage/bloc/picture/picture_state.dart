part of 'picture_bloc.dart';

abstract class PictureState extends Equatable {
  const PictureState();

  @override
  List<Object?> get props => [];
}

class PictureInProgress extends PictureState {
  @override
  String toString() => 'PictureInProgress';
}

class PictureFailure extends PictureState {
  final String message;
  final String id;

  const PictureFailure(
    this.message, {
    required this.id,
  });

  @override
  List<Object> get props => [message, id];

  @override
  String toString() => 'PictureFailure(message: $message)';
}

class PictureSuccess extends PictureState {
  final Picture picture;

  const PictureSuccess({required this.picture});

  @override
  List<Object> get props => [picture];

  @override
  String toString() => 'PictureSuccess(picture: $picture)';
}
