import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

part 'topic_detail_event.dart';
part 'topic_detail_state.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  final BoardRepository boardRepository;

  TopicDetailBloc({
    @required this.boardRepository,
  }) : super(TopicDetailInProgress());

  @override
  Stream<TopicDetailState> mapEventToState(
    TopicDetailEvent event,
  ) async* {
    final currentState = state;
    if (event is TopicDetailFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is TopicDetailSuccess && !event.refresh) {
          final results = await boardRepository.topicDetail(
            topicId: event.topicId,
            descending: event.descending,
            after: currentState.pageInfo.endCursor,
          );
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: currentState.comments + results.item1.comments,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          final results = await boardRepository.topicDetail(
            topicId: event.topicId,
            descending: event.descending,
            cache: !event.refresh,
          );
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: results.item1.comments,
            pageInfo: results.item2,
          );
        }
      } catch (e) {
        yield TopicDetailFailure(
          e.message,
          topicId: event.topicId,
        );
      }
    }
  }
}

bool _hasReachedMax(TopicDetailState currentState) {
  if (currentState is TopicDetailSuccess) {
    return currentState.hasReachedMax;
  }
  return false;
}
