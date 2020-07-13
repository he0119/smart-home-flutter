part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent {
  const StorageDetailEvent();

  @override
  List<Object> get props => [];
}

class StorageDetailRoot extends StorageDetailEvent {}

class StorageDetailRootRefreshed extends StorageDetailEvent {}

class StorageDetailChanged extends StorageDetailEvent {
  final String id;

  const StorageDetailChanged({@required this.id});

  @override
  String toString() => 'StorageDetailChanged { id: $id }';
}

class StorageDetailRefreshed extends StorageDetailEvent {
  final String id;

  const StorageDetailRefreshed({@required this.id});

  @override
  String toString() => 'StorageDetailRefreshed { id: $id }';
}
