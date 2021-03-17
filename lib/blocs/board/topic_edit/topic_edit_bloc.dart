import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/board.dart';
import 'package:smarthome/repositories/board_repository.dart';

part 'topic_edit_event.dart';
part 'topic_edit_state.dart';

class TopicEditBloc extends Bloc<TopicEditEvent, TopicEditState> {
  final BoardRepository boardRepository;

  TopicEditBloc({
    required this.boardRepository,
  }) : super(TopicInProgress());

  @override
  Stream<TopicEditState> mapEventToState(
    TopicEditEvent event,
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
        yield TopicFailure(e.toString());
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
        yield TopicFailure(e.toString());
      }
    }
    if (event is TopicDeleted) {
      yield TopicInProgress();
      try {
        await boardRepository.deleteTopic(topicId: event.topic.id);
        yield TopicDeleteSuccess(topic: event.topic);
      } catch (e) {
        yield TopicFailure(e.toString());
      }
    }
    if (event is TopicClosed) {
      yield TopicInProgress();
      try {
        await boardRepository.closeTopic(topicId: event.topic.id);
        yield TopicCloseSuccess(topic: event.topic);
      } catch (e) {
        yield TopicFailure(e.toString());
      }
    }
    if (event is TopicReopened) {
      yield TopicInProgress();
      try {
        await boardRepository.reopenTopic(topicId: event.topic.id);
        yield TopicReopenSuccess(topic: event.topic);
      } catch (e) {
        yield TopicFailure(e.toString());
      }
    }
    if (event is TopicPinned) {
      yield TopicInProgress();
      try {
        await boardRepository.pinTopic(topicId: event.topic.id);
        yield TopicPinSuccess(topic: event.topic);
      } catch (e) {
        yield TopicFailure(e.toString());
      }
    }
    if (event is TopicUnpinned) {
      yield TopicInProgress();
      try {
        await boardRepository.unpinTopic(topicId: event.topic.id);
        yield TopicUnpinSuccess(topic: event.topic);
      } catch (e) {
        yield TopicFailure(e.toString());
      }
    }
  }
}
