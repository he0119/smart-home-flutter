part of 'picture_edit_bloc.dart';

abstract class PictureEditEvent extends Equatable {
  const PictureEditEvent();

  @override
  List<Object> get props => [];
}

class PictureAdded extends PictureEditEvent {
  final String itemId;
  final String description;
  final File file;
  final double boxX;
  final double boxY;
  final double boxH;
  final double boxW;

  const PictureAdded({
    @required this.itemId,
    @required this.file,
    @required this.boxX,
    @required this.boxY,
    @required this.boxH,
    @required this.boxW,
    this.description,
  });

  @override
  List<Object> get props => [itemId, description, boxX, boxY, boxH, boxW];

  @override
  String toString() => 'PictureAdded { description: $description }';
}

class PictureDeleted extends PictureEditEvent {
  final Picture picture;

  const PictureDeleted({@required this.picture});

  @override
  List<Object> get props => [picture];

  @override
  String toString() => 'PictureDeleted { name: ${picture.id} }';
}

class PictureUpdated extends PictureEditEvent {
  final String id;
  final String description;
  final File file;
  final double boxX;
  final double boxY;
  final double boxH;
  final double boxW;

  const PictureUpdated({
    @required this.id,
    this.description,
    this.file,
    this.boxX,
    this.boxY,
    this.boxH,
    this.boxW,
  });

  @override
  List<Object> get props => [id, description, boxX, boxY, boxH, boxW];

  @override
  String toString() => 'PictureUpdated { id: $id }';
}
