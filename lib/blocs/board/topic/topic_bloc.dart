import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'topic_event.dart';
part 'topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final BoardRepository boardRepository;

  TopicBloc({@required this.boardRepository}) : super(TopicInitial());

  @override
  Stream<TopicState> mapEventToState(
    TopicEvent event,
  ) async* {
    if (event is TopicAdded) {
      yield TopicInProgress();
      try {
        Topic topic = await boardRepository.addTopic(
          title: event.title,
          description: event.description,
        );
        yield TopicAddSuccess(topic: topic);
      } catch (e) {
        yield TopicError(message: e.message);
      }
    }
    if (event is TopicUpdated) {
      yield TopicInProgress();
      try {
        Topic topic = await boardRepository.updateTopic(
          id: event.id,
          title: event.title,
          description: event.description,
        );
        yield TopicUpdateSuccess(topic: topic);
      } catch (e) {
        yield TopicError(message: e.message);
      }
    }
    if (event is TopicDeleted) {
      yield TopicInProgress();
      try {
        await boardRepository.deleteTopic(topicId: event.topic.id);
        yield TopicDeleteSuccess(topic: event.topic);
      } catch (e) {
        yield TopicError(message: e.message);
      }
    }
  }
}
