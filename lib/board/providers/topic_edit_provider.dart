import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/providers.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'topic_edit_provider.g.dart';

/// Topic edit state
class TopicEditState {
  final TopicEditStatus status;
  final String errorMessage;
  final Topic? topic;

  const TopicEditState({
    this.status = TopicEditStatus.initial,
    this.errorMessage = '',
    this.topic,
  });

  TopicEditState copyWith({
    TopicEditStatus? status,
    String? errorMessage,
    Topic? topic,
  }) {
    return TopicEditState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      topic: topic ?? this.topic,
    );
  }

  @override
  String toString() {
    return 'TopicEditState(status: $status, topic: ${topic?.title})';
  }
}

enum TopicEditStatus {
  initial,
  loading,
  addSuccess,
  updateSuccess,
  deleteSuccess,
  closeSuccess,
  reopenSuccess,
  pinSuccess,
  unpinSuccess,
  failure,
}

/// Topic edit notifier
@riverpod
class TopicEdit extends _$TopicEdit {
  @override
  TopicEditState build() {
    return const TopicEditState();
  }

  Future<void> addTopic({required String title, String? description}) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final topic = await boardRepository.addTopic(
        title: title,
        description: description ?? '',
      );
      state = state.copyWith(status: TopicEditStatus.addSuccess, topic: topic);
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> updateTopic({
    required String id,
    required String title,
    String? description,
  }) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final topic = await boardRepository.updateTopic(
        id: id,
        title: title,
        description: description ?? '',
      );
      state = state.copyWith(
        status: TopicEditStatus.updateSuccess,
        topic: topic,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deleteTopic(Topic topic) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.deleteTopic(topicId: topic.id);
      state = state.copyWith(
        status: TopicEditStatus.deleteSuccess,
        topic: topic,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> closeTopic(Topic topic) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.closeTopic(topicId: topic.id);
      state = state.copyWith(
        status: TopicEditStatus.closeSuccess,
        topic: topic,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> reopenTopic(Topic topic) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.reopenTopic(topicId: topic.id);
      state = state.copyWith(
        status: TopicEditStatus.reopenSuccess,
        topic: topic,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> pinTopic(Topic topic) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.pinTopic(topicId: topic.id);
      state = state.copyWith(status: TopicEditStatus.pinSuccess, topic: topic);
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> unpinTopic(Topic topic) async {
    state = state.copyWith(status: TopicEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.unpinTopic(topicId: topic.id);
      state = state.copyWith(
        status: TopicEditStatus.unpinSuccess,
        topic: topic,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  void reset() {
    state = const TopicEditState();
  }
}
