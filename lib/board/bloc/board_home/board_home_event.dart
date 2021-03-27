part of 'board_home_bloc.dart';

abstract class BoardHomeEvent extends Equatable {
  const BoardHomeEvent();

  @override
  List<Object> get props => [];
}

class BoardHomeFetched extends BoardHomeEvent {
  final bool cache;

  BoardHomeFetched({
    this.cache = true,
  });

  @override
  List<Object> get props => [cache];

  @override
  String toString() => 'BoardHomeFetched(cache: $cache)';
}
