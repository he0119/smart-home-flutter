part of 'recycle_bin_bloc.dart';

abstract class RecycleBinEvent extends Equatable {
  const RecycleBinEvent();
}

class RecycleBinFetched extends RecycleBinEvent {
  final bool refresh;

  RecycleBinFetched({
    this.refresh = false,
  });

  @override
  List<Object> get props => [refresh];

  @override
  String toString() => 'RecycleBinFetched(refresh: $refresh)';
}
