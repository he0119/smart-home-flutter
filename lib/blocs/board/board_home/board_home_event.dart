part of 'board_home_bloc.dart';

abstract class BoardHomeEvent extends Equatable {
  const BoardHomeEvent();

  @override
  List<Object> get props => [];
}

class BoardHomeFetched extends BoardHomeEvent {
  @override
  String toString() => 'BoardHomeFetched';
}

class BoardHomeRefreshed extends BoardHomeEvent {
  @override
  String toString() => 'BoardHomeRefreshed';
}
