import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/board/providers/board_home_provider.dart'
    as board_home;
import 'package:smarthome/board/providers/topic_edit_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../helpers/board_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockBoardRepository mockBoardRepository;
  late ProviderContainer container;

  setUp(() {
    mockBoardRepository = MockBoardRepository();
    container = ProviderContainer.test(
      overrides: [
        board_home.boardRepositoryProvider.overrideWithValue(
          mockBoardRepository,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('addTopic updates state', () async {
    when(
      mockBoardRepository.addTopic(
        title: anyNamed('title'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => buildTopic(id: 'topic-1'));

    await container.read(topicEditProvider.notifier).addTopic(title: 'Title');

    final state = container.read(topicEditProvider);
    expect(state.status, TopicEditStatus.addSuccess);
    expect(state.topic?.id, 'topic-1');
  });

  test('pinTopic surfaces repository errors', () async {
    when(
      mockBoardRepository.pinTopic(topicId: anyNamed('topicId')),
    ).thenThrow(MyException('置顶失败'));

    await container
        .read(topicEditProvider.notifier)
        .pinTopic(buildTopic(id: 'topic-1'));

    final state = container.read(topicEditProvider);
    expect(state.status, TopicEditStatus.failure);
    expect(state.errorMessage, '置顶失败');
  });

  test('reset clears edit state', () {
    container.read(topicEditProvider.notifier).state = TopicEditState(
      status: TopicEditStatus.addSuccess,
      topic: buildTopic(),
    );

    container.read(topicEditProvider.notifier).reset();

    final state = container.read(topicEditProvider);
    expect(state.status, TopicEditStatus.initial);
    expect(state.topic, isNull);
  });
}
