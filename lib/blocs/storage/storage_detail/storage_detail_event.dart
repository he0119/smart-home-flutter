part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent extends Equatable {
  const StorageDetailEvent();

  @override
  List<Object> get props => [];
}

class StorageDetailFetched extends StorageDetailEvent {
  final String name;
  final String id;
  final bool refresh;

  const StorageDetailFetched({
    @required this.name,
    this.id,
    this.refresh = false,
  });

  @override
  List<Object> get props => [name, id, refresh];

  @override
  String toString() =>
      'StorageDetailFetched(name: $name, id: $id, refresh: $refresh)';
}
