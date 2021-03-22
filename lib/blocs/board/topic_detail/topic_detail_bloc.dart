import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/repositories/repositories.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

part 'topic_detail_event.dart';
part 'topic_detail_state.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  final BoardRepository boardRepository;

  TopicDetailBloc({
    required this.boardRepository,
  }) : super(TopicDetailInProgress());

  @override
  Stream<TopicDetailState> mapEventToState(
    TopicDetailEvent event,
  ) async* {
    final TopicDetailState currentState = state;
    if (event is TopicDetailFetched) {
      try {
        // 如果需要刷新，则显示加载界面
        // 因为需要请求网络最好提示用户
        if (event.showInProgress && !event.cache) {
          yield TopicDetailInProgress();
        }
        if (event.cache &&
            currentState is TopicDetailSuccess &&
            !currentState.hasReachedMax) {
          // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
          // 则获取下一页
          final results = await boardRepository.topicDetail(
            topicId: event.topicId,
            descending: event.descending,
            after: currentState.pageInfo.endCursor,
            cache: false,
          );
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: currentState.comments + results.item2,
            pageInfo: currentState.pageInfo.copyWith(results.item3),
          );
        } else {
          // 其他情况根据设置看是否需要打开缓存，并获取第一页
          Tuple3<Topic, List<Comment>, PageInfo> results;
          if (currentState is TopicDetailSuccess) {
            results = await boardRepository.topicDetail(
              topicId: currentState.topic.id,
              descending: event.descending,
              cache: event.cache,
            );
          } else {
            results = await boardRepository.topicDetail(
              topicId: event.topicId,
              descending: event.descending,
              cache: event.cache,
            );
          }
          yield TopicDetailSuccess(
            topic: results.item1,
            comments: results.item2,
            pageInfo: results.item3,
          );
        }
      } on MyException catch (e) {
        yield TopicDetailFailure(
          e.message,
          topicId: event.topicId!,
        );
      }
    }
  }
}
