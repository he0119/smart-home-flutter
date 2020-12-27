import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:tuple/tuple.dart';

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
    if (event is TopicDetailFetched) {
      try {
        if (currentState is TopicDetailSuccess &&
            !_hasReachedMax(currentState) &&
            event.cache) {
          final results = await boardRepository.topicDetail(
            topicId: event.topicId,
            descending: event.descending,
            after: currentState.pageInfo.endCursor,
          );
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: currentState.comments + results.item2,
            pageInfo: currentState.pageInfo.copyWith(results.item3),
          );
        } else {
          Tuple3<Topic, List<Comment>, PageInfo> results;
          if (currentState is TopicDetailSuccess) {
            results = await boardRepository.topicDetail(
              topicId: currentState.topic.id,
              descending: event.descending,
              cache: event.cache,
            );
          } else {
            results = await boardRepository.topicDetail(
              topicId: event.topicId,
              descending: event.descending,
              cache: event.cache,
            );
          }
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: results.item2,
            pageInfo: results.item3,
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
