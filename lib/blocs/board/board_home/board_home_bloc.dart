import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'board_home_event.dart';
part 'board_home_state.dart';

class BoardHomeBloc extends Bloc<BoardHomeEvent, BoardHomeState> {
  @override
  BoardHomeState get initialState => BoardHomeInitial();

  @override
  Stream<BoardHomeState> mapEventToState(
    BoardHomeEvent event,
  ) async* {
    if (event is BoardHomeStarted) {
      try {
        yield BoardHomeInProgress();
        List<Topic> topics = await boardRepository.topics();
        yield BoardHomeSuccess(topics: topics);
      } on GraphQLApiException catch (e) {
        yield BoardHomeError(message: e.message);
      }
    }
    if (event is BoardHomeRefreshed) {
      try {
        yield BoardHomeInProgress();
        List<Topic> topics = await boardRepository.topics(cache: false);
        yield BoardHomeSuccess(topics: topics);
      } on GraphQLApiException catch (e) {
        yield BoardHomeError(message: e.message);
      }
    }
  }
}