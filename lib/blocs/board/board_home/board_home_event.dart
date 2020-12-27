part of 'board_home_bloc.dart';

abstract class BoardHomeEvent extends Equatable {
  const BoardHomeEvent();

  @override
  List<Object> get props => [];
}

class BoardHomeFetched extends BoardHomeEvent {
  final bool refresh;

  BoardHomeFetched({
    this.refresh = false,
  });

  @override
  List<Object> get props => [refresh];

  @override
  String toString() => 'BoardHomeFetched(refresh: $refresh)';
}
