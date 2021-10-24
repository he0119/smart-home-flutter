part of 'recycle_bin_bloc.dart';

abstract class RecycleBinEvent extends Equatable {
  const RecycleBinEvent();
}

class RecycleBinFetched extends RecycleBinEvent {
  final bool cache;

  const RecycleBinFetched({
    this.cache = true,
  });

  @override
  List<Object> get props => [cache];

  @override
  String toString() => 'RecycleBinFetched(cache: $cache)';
}
