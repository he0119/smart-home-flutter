part of 'picture_edit_bloc.dart';

abstract class PictureEditState extends Equatable {
  const PictureEditState();

  @override
  List<Object> get props => [];
}

class PictureEditInitial extends PictureEditState {
  @override
  String toString() => 'PictureEditInitial';
}

class PictureEditInProgress extends PictureEditState {
  @override
  String toString() => 'PictureEditInProgress';
}

class PictureEditFailure extends PictureEditState {
  final String message;

  const PictureEditFailure(this.message);

  @override
  String toString() => 'PictureEditFailure(message: $message)';
}

class PictureAddSuccess extends PictureEditState {
  final Picture picture;

  const PictureAddSuccess({required this.picture});

  @override
  String toString() => 'PictureAddSuccess(picture: $picture)';
}

class PictureUpdateSuccess extends PictureEditState {
  final Picture picture;

  const PictureUpdateSuccess({required this.picture});

  @override
  String toString() => 'PictureUpdateSuccess(picture: $picture)';
}

class PictureDeleteSuccess extends PictureEditState {
  final Picture picture;

  const PictureDeleteSuccess({required this.picture});

  @override
  String toString() => 'PictureDeleteSuccess(picture: $picture)';
}
