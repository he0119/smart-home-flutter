part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent extends Equatable {
  const StorageDetailEvent();

  @override
  List<Object?> get props => [];
}

class StorageDetailFetched extends StorageDetailEvent {
  final String name;
  final String? id;
  final bool cache;

  const StorageDetailFetched({
    required this.name,
    this.id,
    this.cache = true,
  });

  @override
  List<Object?> get props => [name, id, cache];

  @override
  String toString() =>
      'StorageDetailFetched(name: $name, id: $id, cache: $cache)';
}
