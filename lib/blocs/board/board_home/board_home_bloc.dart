import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

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
        if (currentState is BoardHomeSuccess && !event.refresh) {
          final results = await boardRepository.topics(
            after: currentState.pageInfo.endCursor,
          );
          yield BoardHomeSuccess(
            topics: currentState.topics + results.item1,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          final results = await boardRepository.topics(
            cache: !event.refresh,
          );
          yield BoardHomeSuccess(
            topics: results.item1,
            pageInfo: results.item2,
          );
        }
      } catch (e) {
        yield BoardHomeFailure(e.message);
      }
    }
  }
}

bool _hasReachedMax(BoardHomeState currentState) {
  if (currentState is BoardHomeSuccess) {
    return currentState.hasReachedMax;
  }
  return false;
}
