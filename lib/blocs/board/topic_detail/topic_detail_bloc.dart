import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'topic_detail_event.dart';
part 'topic_detail_state.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  @override
  TopicDetailState get initialState => TopicDetailInitial();

  @override
  Stream<TopicDetailState> mapEventToState(
    TopicDetailEvent event,
  ) async* {
    if (event is TopicDetailChanged) {
      try {
        yield TopicDetailInProgress();
        List<dynamic> topicDetail =
            await boardRepository.topicDetail(topicId: event.topicId);
        yield TopicDetailSuccess(
            topic: topicDetail[0], comments: topicDetail[1]);
      } on GraphQLApiException catch (e) {
        yield TopicDetailFailure(message: e.message);
      }
    }
    if (event is TopicDetailRefreshed) {
      try {
        yield TopicDetailInProgress();
        List<dynamic> topicDetail =
            await boardRepository.topicDetail(topicId: event.topicId, cache: false);
        yield TopicDetailSuccess(
            topic: topicDetail[0], comments: topicDetail[1]);
      } on GraphQLApiException catch (e) {
        yield TopicDetailFailure(message: e.message);
      }
    }
  }
}
