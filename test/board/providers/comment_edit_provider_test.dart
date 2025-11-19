import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/board/providers/board_home_provider.dart'
    as board_home;
import 'package:smarthome/board/providers/comment_edit_provider.dart';
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

  test('addComment updates state on success', () async {
    when(
      mockBoardRepository.addComment(
        topicId: anyNamed('topicId'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => buildComment(id: 'comment-1'));

    await container
        .read(commentEditProvider.notifier)
        .addComment(topicId: 'topic-1', body: 'Hello');

    final state = container.read(commentEditProvider);
    expect(state.status, CommentEditStatus.addSuccess);
    expect(state.comment?.id, 'comment-1');
  });

  test('deleteComment surfaces repository errors', () async {
    when(
      mockBoardRepository.deleteComment(commentId: anyNamed('commentId')),
    ).thenThrow(MyException('删除失败'));

    await container
        .read(commentEditProvider.notifier)
        .deleteComment(buildComment(id: 'comment-1'));

    final state = container.read(commentEditProvider);
    expect(state.status, CommentEditStatus.failure);
    expect(state.errorMessage, '删除失败');
  });

  test('reset clears edit state', () {
    container.read(commentEditProvider.notifier).state = CommentEditState(
      status: CommentEditStatus.addSuccess,
      comment: buildComment(),
    );

    container.read(commentEditProvider.notifier).reset();

    final state = container.read(commentEditProvider);
    expect(state.status, CommentEditStatus.initial);
    expect(state.comment, isNull);
  });
}
