import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'board_home_event.dart';
part 'board_home_state.dart';

enum BoardHomeStatus { initial, loading, success, failure }

class BoardHomeBloc extends Bloc<BoardHomeEvent, BoardHomeState> {
  final BoardRepository boardRepository;

  BoardHomeBloc({
    required this.boardRepository,
  }) : super(const BoardHomeState()) {
    on<BoardHomeFetched>(_onBoardHomeFetched);
  }

  FutureOr<void> _onBoardHomeFetched(
      BoardHomeFetched event, Emitter<BoardHomeState> emit) async {
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (!event.cache) {
        emit(state.copyWith(status: BoardHomeStatus.loading));
      }
      if (event.cache &&
          state.status == BoardHomeStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final results = await boardRepository.topics(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        emit(state.copyWith(
          status: BoardHomeStatus.success,
          topics: state.topics + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        ));
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        final results = await boardRepository.topics(
          cache: event.cache,
        );
        emit(state.copyWith(
          status: BoardHomeStatus.success,
          topics: results.item1,
          pageInfo: results.item2,
        ));
      }
    } on MyException catch (e) {
      emit(state.copyWith(
        status: BoardHomeStatus.failure,
        error: e.message,
      ));
    }
  }
}
