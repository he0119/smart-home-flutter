import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:smart_home/graphql/mutations/board/mutations.dart';
import 'package:smart_home/graphql/queries/board/queries.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/utils/graphql_helper.dart';
import 'package:tuple/tuple.dart';

class BoardRepository {
  final GraphQLApiClient graphqlApiClient;

  BoardRepository({@required this.graphqlApiClient});

  Future<Comment> addComment({
    @required String topicId,
    @required String body,
    String parentId,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addCommentMutation),
      variables: {
        'input': {
          'topicId': topicId,
          'body': body,
          'parentId': parentId,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addComment']['comment'];
    final Comment commentObject = Comment.fromJson(json);
    return commentObject;
  }

  Future<Topic> addTopic({
    @required String title,
    @required String description,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addTopicMutation),
      variables: {
        'input': {
          'title': title,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['addTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<Topic> closeTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(closeTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['closeTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<Topic> pinTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(pinTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> topicJson = result.data['pinTopic']['topic'];
    final Topic topic = Topic.fromJson(topicJson);
    return topic;
  }

  Future<Topic> unpinTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(unpinTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> topicJson = result.data['unpinTopic']['topic'];
    final Topic topic = Topic.fromJson(topicJson);
    return topic;
  }

  Future<String> deleteComment({@required String commentId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteCommentMutation),
      variables: {
        'input': {'commentId': commentId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data['deleteComment']['commentId'];
  }

  Future<String> deleteTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data['deleteTopic']['topicId'];
  }

  Future<Topic> reopenTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      document: gql(reopenTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['reopenTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }

  /// 话题详情的数据
  /// 评论可选择是否按创建时间倒序，默认为正序
  Future<Tuple2<Topic, List<Comment>>> topicDetail({
    @required String topicId,
    bool descending = false,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(topicDetailQuery),
      variables: {
        'topicId': topicId,
        'orderBy': descending ? '-created_at' : 'created_at',
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final json = results.data.flattenConnection;

    final dynamic topicJson = json['topic'];
    final Topic topic = Topic.fromJson(topicJson);

    final List<dynamic> commentsJson = json['comments'];
    final List<Comment> comments =
        commentsJson.map((e) => Comment.fromJson(e)).toList();

    return Tuple2(topic, comments);
  }

  /// 话题列表
  ///
  /// topics, (topicsEndCursor, topicsHasNextPage)
  Future<Tuple2<List<Topic>, Tuple2<String, bool>>> topics({
    String after,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(topicsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    // 是否还有下一页
    final String endCursor = results.data['topics']['pageInfo']['endCursor'];
    final bool hasNextPage = results.data['topics']['pageInfo']['hasNextPage'];

    final List<dynamic> topicsJson = results.data.flattenConnection['topics'];
    final List<Topic> topics =
        topicsJson.map((e) => Topic.fromJson(e)).toList();

    return Tuple2(topics, Tuple2(endCursor, hasNextPage));
  }

  Future<Comment> updateComment({
    @required String id,
    @required String body,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(updateCommentMutation),
      variables: {
        'input': {
          'id': id,
          'body': body,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateComment']['comment'];
    final Comment commentObject = Comment.fromJson(json);
    return commentObject;
  }

  Future<Topic> updateTopic({
    @required String id,
    @required String title,
    @required String description,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(updateTopicMutation),
      variables: {
        'input': {
          'id': id,
          'title': title,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['updateTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }
}
