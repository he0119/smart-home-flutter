import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'board_home_event.dart';
part 'board_home_state.dart';

class BoardHomeBloc extends Bloc<BoardHomeEvent, BoardHomeState> {
  final BoardRepository boardRepository;

  BoardHomeBloc({@required this.boardRepository})
      : super(BoardHomeInProgress());

  @override
  Stream<BoardHomeState> mapEventToState(
    BoardHomeEvent event,
  ) async* {
    if (event is BoardHomeStarted) {
      try {
        final currentState = state;
        if (currentState is! BoardHomeSuccess) {
          yield BoardHomeInProgress();
        }
        List<Topic> topics = await boardRepository.topics(cache: false);
        yield BoardHomeSuccess(topics: topics);
      } catch (e) {
        yield BoardHomeFailure(e.message);
      }
    }
    if (event is BoardHomeRefreshed) {
      try {
        yield BoardHomeInProgress();
        List<Topic> topics = await boardRepository.topics(cache: false);
        yield BoardHomeSuccess(topics: topics);
      } catch (e) {
        yield BoardHomeFailure(e.message);
      }
    }
  }
}
