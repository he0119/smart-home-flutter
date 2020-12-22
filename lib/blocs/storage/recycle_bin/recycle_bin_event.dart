part of 'recycle_bin_bloc.dart';

abstract class RecycleBinEvent {
  const RecycleBinEvent();
}

class RecycleBinRefreshed extends RecycleBinEvent {
  @override
  String toString() => 'RecycleBinRefreshed';
}

class RecycleBinFetched extends RecycleBinEvent {
  @override
  String toString() => 'RecycleBinFetched';
}
