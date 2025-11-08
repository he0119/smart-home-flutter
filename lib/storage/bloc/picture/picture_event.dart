part of 'picture_bloc.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();

  @override
  List<Object> get props => [];
}

class PictureStarted extends PictureEvent {
  final String id;

  const PictureStarted({required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'PictureStarted(id: $id)';
}

class PictureRefreshed extends PictureEvent {
  @override
  String toString() => 'PictureRefreshed';
}
