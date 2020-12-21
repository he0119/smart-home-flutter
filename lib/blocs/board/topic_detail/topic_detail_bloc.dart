import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'topic_detail_event.dart';
part 'topic_detail_state.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  final BoardRepository boardRepository;

  TopicDetailBloc({@required this.boardRepository})
      : super(TopicDetailInProgress());

  @override
  Stream<TopicDetailState> mapEventToState(
    TopicDetailEvent event,
  ) async* {
    if (event is TopicDetailChanged) {
      try {
        yield TopicDetailInProgress();
        final topicDetail =
            await boardRepository.topicDetail(topicId: event.topicId);
        yield TopicDetailSuccess(
            topic: topicDetail.item1, comments: topicDetail.item2);
      } catch (e) {
        yield TopicDetailFailure(
          e.message,
          topicId: event.topicId,
        );
      }
    }
    final currentState = state;
    if (event is TopicDetailRefreshed && currentState is TopicDetailSuccess) {
      try {
        final topicDetail = await boardRepository.topicDetail(
            topicId: currentState.topic.id, cache: false);
        yield TopicDetailSuccess(
            topic: topicDetail.item1, comments: topicDetail.item2);
      } catch (e) {
        yield TopicDetailFailure(
          e.message,
          topicId: currentState.topic.id,
        );
      }
    }
  }
}
