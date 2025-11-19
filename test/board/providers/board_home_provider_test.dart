import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/board/providers/board_home_provider.dart'
    as board_home;
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
        board_home.boardRepositoryProvider.overrideWithValue(
          mockBoardRepository,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'boardRepositoryProvider composes BoardRepository from GraphQL client',
    () {
      final mockGraphQLApiClient = MockGraphQLApiClient();
      final localContainer = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
        ],
      );

      final repository = localContainer.read(
        board_home.boardRepositoryProvider,
      );
      expect(repository.graphqlApiClient, mockGraphQLApiClient);

      localContainer.dispose();
    },
  );

  test('boardHomeProvider loads topics on initialization', () async {
    when(mockBoardRepository.topics(cache: true)).thenAnswer(
      (_) async => Tuple2([
        buildTopic(id: 'topic-1'),
      ], const PageInfo(hasNextPage: false)),
    );

    keepProviderAlive(container, board_home.boardHomeProvider);
    container.read(board_home.boardHomeProvider);
    await _flush();

    final state = container.read(board_home.boardHomeProvider);
    expect(state.status, board_home.BoardHomeStatus.success);
    expect(state.topics, hasLength(1));
  });

  test('boardHomeProvider supports pagination', () async {
    when(mockBoardRepository.topics(cache: true)).thenAnswer(
      (_) async => Tuple2([
        buildTopic(id: 'topic-1'),
      ], const PageInfo(hasNextPage: true, endCursor: 'cursor-1')),
    );
    when(
      mockBoardRepository.topics(cache: false, after: 'cursor-1'),
    ).thenAnswer(
      (_) async => Tuple2([
        buildTopic(id: 'topic-2'),
      ], const PageInfo(hasNextPage: false)),
    );

    keepProviderAlive(container, board_home.boardHomeProvider);
    container.read(board_home.boardHomeProvider);
    await _flush();

    await container.read(board_home.boardHomeProvider.notifier).fetch();

    final state = container.read(board_home.boardHomeProvider);
    expect(state.topics.map((e) => e.id), ['topic-1', 'topic-2']);
  });

  test('boardHomeProvider handles repository failures', () async {
    when(
      mockBoardRepository.topics(cache: true),
    ).thenThrow(MyException('获取失败'));

    keepProviderAlive(container, board_home.boardHomeProvider);
    container.read(board_home.boardHomeProvider);
    await _flush();

    final state = container.read(board_home.boardHomeProvider);
    expect(state.status, board_home.BoardHomeStatus.failure);
    expect(state.errorMessage, '获取失败');
  });
}
