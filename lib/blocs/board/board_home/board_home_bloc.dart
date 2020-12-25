import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'board_home_event.dart';
part 'board_home_state.dart';

class BoardHomeBloc extends Bloc<BoardHomeEvent, BoardHomeState> {
  final BoardRepository boardRepository;

  BoardHomeBloc({
    @required this.boardRepository,
  }) : super(BoardHomeInitial());

  @override
  Stream<BoardHomeState> mapEventToState(
    BoardHomeEvent event,
  ) async* {
    final currentState = state;
    if (event is BoardHomeFetched && !_hasReachedMax(currentState)) {
      try {
        // 获取第一页数据
        if (currentState is BoardHomeInitial) {
          final results = await boardRepository.topics();
          yield BoardHomeSuccess(
            topics: results.item1,
            topicsEndCursor: results.item2.item1,
            hasReachedMax: !results.item2.item2,
          );
          return;
        }
        // 获取下一页数据
        if (currentState is BoardHomeSuccess) {
          final results =
              await boardRepository.topics(after: currentState.topicsEndCursor);
          yield BoardHomeSuccess(
            topics: currentState.topics + results.item1,
            topicsEndCursor: results.item2.item1,
            hasReachedMax: !results.item2.item2,
          );
        }
      } catch (e) {
        yield BoardHomeFailure(e.message);
      }
    }
    if (event is BoardHomeRefreshed) {
      final results = await boardRepository.topics(cache: false);
      yield BoardHomeSuccess(
        topics: results.item1,
        topicsEndCursor: results.item2.item1,
        hasReachedMax: !results.item2.item2,
      );
      return;
    }
  }
}

bool _hasReachedMax(BoardHomeState state) =>
    state is BoardHomeSuccess && state.hasReachedMax;
