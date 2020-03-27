part of 'board_home_bloc.dart';

abstract class BoardHomeEvent extends Equatable {
  const BoardHomeEvent();

  @override
  List<Object> get props => [];
}

class BoardHomeStarted extends BoardHomeEvent {}

class BoardHomeRefreshed extends BoardHomeEvent {}
