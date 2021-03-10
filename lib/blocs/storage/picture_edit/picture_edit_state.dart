part of 'picture_edit_bloc.dart';

abstract class PictureEditState extends Equatable {
  const PictureEditState();

  @override
  List<Object> get props => [];
}

class PictureEditInitial extends PictureEditState {}

class PictureEditInProgress extends PictureEditState {}

class PictureEditFailure extends PictureEditState {
  final String message;

  const PictureEditFailure(this.message);

  @override
  String toString() => 'PictureEditFailure { message: $message }';
}

class PictureAddSuccess extends PictureEditState {
  final Picture picture;

  const PictureAddSuccess({@required this.picture});

  @override
  String toString() => 'PictureAddSuccess { Picture: ${picture.id} }';
}

class PictureUpdateSuccess extends PictureEditState {
  final Picture picture;

  const PictureUpdateSuccess({@required this.picture});

  @override
  String toString() => 'PictureUpdateSuccess { Picture: ${picture.id} }';
}

class PictureDeleteSuccess extends PictureEditState {
  final Picture picture;

  const PictureDeleteSuccess({@required this.picture});

  @override
  String toString() => 'PictureDeleteSuccess { Picture: ${picture.id} }';
}
