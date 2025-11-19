import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/topic_detail_provider.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/board_test_utils.dart';
import '../../helpers/provider_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockBoardRepository mockBoardRepository;
  late ProviderContainer container;

  setUp(() {
    mockBoardRepository = MockBoardRepository();
    container = ProviderContainer.test(
      overrides: [
        boardRepositoryProvider.overrideWithValue(mockBoardRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Tuple3<Topic, List<Comment>, PageInfo> buildDetail({String after = ''}) =>
      Tuple3(
        buildTopic(
          id: 'topic-1',
          comments: [buildComment(id: 'comment-$after')],
        ),
        [buildComment(id: 'comment-$after')],
        PageInfo(hasNextPage: true, endCursor: 'cursor-$after'),
      );

  test('initialize loads topic detail', () async {
    when(
      mockBoardRepository.topicDetail(
        topicId: anyNamed('topicId'),
        descending: anyNamed('descending'),
        cache: anyNamed('cache'),
        after: anyNamed('after'),
      ),
    ).thenAnswer((_) async => buildDetail(after: '1'));

    final provider = topicDetailProvider('topic-1');
    keepProviderAlive(container, provider);
    container.read(provider.notifier).initialize();
    await _flush();

    final state = container.read(provider);
    expect(state.status, TopicDetailStatus.success);
    expect(state.topic.id, 'topic-1');
    expect(state.comments, hasLength(1));
  });

  test('fetchMore appends additional comments', () async {
    when(
      mockBoardRepository.topicDetail(
        topicId: anyNamed('topicId'),
        descending: anyNamed('descending'),
        cache: anyNamed('cache'),
        after: anyNamed('after'),
      ),
    ).thenAnswer((invocation) async {
      final cache = invocation.namedArguments[const Symbol('cache')] as bool?;
      if (cache == false &&
          invocation.namedArguments[const Symbol('after')] == 'cursor-1') {
        return buildDetail(after: '2');
      }
      return buildDetail(after: '1');
    });

    final provider = topicDetailProvider('topic-1');
    keepProviderAlive(container, provider);
    final notifier = container.read(provider.notifier);
    notifier.initialize();
    await _flush();

    await notifier.fetchMore();

    final state = container.read(provider);
    expect(state.comments.map((e) => e.id), ['comment-1', 'comment-2']);
  });

  test('refresh propagates repository errors', () async {
    when(
      mockBoardRepository.topicDetail(
        topicId: anyNamed('topicId'),
        descending: anyNamed('descending'),
        cache: anyNamed('cache'),
        after: anyNamed('after'),
      ),
    ).thenAnswer((invocation) async {
      final cache = invocation.namedArguments[const Symbol('cache')] as bool?;
      if (cache == false) {
        throw MyException('刷新失败');
      }
      return buildDetail(after: '1');
    });

    final provider = topicDetailProvider('topic-1');
    keepProviderAlive(container, provider);
    final notifier = container.read(provider.notifier);
    notifier.initialize();
    await _flush();

    notifier.refresh();
    await _flush();

    final state = container.read(provider);
    expect(state.status, TopicDetailStatus.failure);
    expect(state.errorMessage, '刷新失败');
  });
}
