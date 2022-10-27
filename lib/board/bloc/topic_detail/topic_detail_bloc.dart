import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

part 'topic_detail_event.dart';
part 'topic_detail_state.dart';

enum TopicDetailStatus { initial, loading, success, failure }

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  final BoardRepository boardRepository;

  TopicDetailBloc({
    required this.boardRepository,
  }) : super(const TopicDetailState()) {
    on<TopicDetailFetched>(_onTopicDetailFetched);
  }

  FutureOr<void> _onTopicDetailFetched(
      TopicDetailFetched event, Emitter<TopicDetailState> emit) async {
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (event.showInProgress && !event.cache) {
        emit(state.copyWith(status: TopicDetailStatus.loading));
      }
      if (event.cache &&
          state.status == TopicDetailStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final results = await boardRepository.topicDetail(
          topicId: event.id,
          descending: event.descending,
          after: state.pageInfo.endCursor,
          cache: false,
        );
        emit(state.copyWith(
          status: TopicDetailStatus.success,
          topic: results.item1,
          comments: state.comments + results.item2,
          pageInfo: state.pageInfo.copyWith(results.item3),
        ));
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        Tuple3<Topic, List<Comment>, PageInfo> results;
        if (state.status == TopicDetailStatus.success) {
          results = await boardRepository.topicDetail(
            topicId: state.topic.id,
            descending: event.descending,
            cache: event.cache,
          );
        } else {
          results = await boardRepository.topicDetail(
            topicId: event.id,
            descending: event.descending,
            cache: event.cache,
          );
        }
        emit(state.copyWith(
          status: TopicDetailStatus.success,
          topic: results.item1,
          comments: results.item2,
          pageInfo: results.item3,
        ));
      }
    } on MyException catch (e) {
      emit(state.copyWith(
        status: TopicDetailStatus.failure,
        error: e.message,
      ));
    }
  }
}
