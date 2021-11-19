import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'topic_edit_event.dart';
part 'topic_edit_state.dart';

class TopicEditBloc extends Bloc<TopicEditEvent, TopicEditState> {
  final BoardRepository boardRepository;

  TopicEditBloc({
    required this.boardRepository,
  }) : super(TopicInProgress()) {
    on<TopicAdded>(_onTopicAdded);
    on<TopicUpdated>(_onTopicUpdated);
    on<TopicDeleted>(_onTopicDeleted);
    on<TopicClosed>(_onTopicClosed);
    on<TopicReopened>(_onTopicReopened);
    on<TopicPinned>(_onTopicPinned);
    on<TopicUnpinned>(_onTopicUnpinned);
  }

  FutureOr<void> _onTopicAdded(
      TopicAdded event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      final topic = await boardRepository.addTopic(
        title: event.title,
        description: event.description,
      );
      emit(TopicAddSuccess(topic: topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicUpdated(
      TopicUpdated event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      final topic = await boardRepository.updateTopic(
        id: event.id,
        title: event.title,
        description: event.description,
      );
      emit(TopicUpdateSuccess(topic: topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicDeleted(
      TopicDeleted event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      await boardRepository.deleteTopic(topicId: event.topic.id);
      emit(TopicDeleteSuccess(topic: event.topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicClosed(
      TopicClosed event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      await boardRepository.closeTopic(topicId: event.topic.id);
      emit(TopicCloseSuccess(topic: event.topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicReopened(
      TopicReopened event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      await boardRepository.reopenTopic(topicId: event.topic.id);
      emit(TopicReopenSuccess(topic: event.topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicPinned(
      TopicPinned event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      await boardRepository.pinTopic(topicId: event.topic.id);
      emit(TopicPinSuccess(topic: event.topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }

  FutureOr<void> _onTopicUnpinned(
      TopicUnpinned event, Emitter<TopicEditState> emit) async {
    emit(TopicInProgress());
    try {
      await boardRepository.unpinTopic(topicId: event.topic.id);
      emit(TopicUnpinSuccess(topic: event.topic));
    } on MyException catch (e) {
      emit(TopicFailure(e.message));
    }
  }
}
