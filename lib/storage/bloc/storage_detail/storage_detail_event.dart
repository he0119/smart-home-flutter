part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent extends Equatable {
  const StorageDetailEvent();
}

class StorageDetailFetched extends StorageDetailEvent {
  final String id;
  final bool cache;

  const StorageDetailFetched({
    required this.id,
    this.cache = true,
  });

  @override
  List<Object?> get props => [id, cache];

  @override
  String toString() => 'StorageDetailFetched(id: $id, cache: $cache)';
}
