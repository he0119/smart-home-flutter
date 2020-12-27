part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent extends Equatable {
  const StorageDetailEvent();

  @override
  List<Object> get props => [];
}

class StorageDetailStarted extends StorageDetailEvent {
  final String name;
  final String id;

  const StorageDetailStarted({
    @required this.name,
    this.id,
  });

  @override
  List<Object> get props => [name, id];

  @override
  String toString() => 'StorageDetailChanged(name: $name, id: $id)';
}

class StorageDetailRefreshed extends StorageDetailEvent {
  @override
  String toString() => 'StorageDetailRefreshed';
}

class StorageDetailFetched extends StorageDetailEvent {
  @override
  String toString() => 'StorageDetailFetched';
}
