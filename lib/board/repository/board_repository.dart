import 'package:graphql/client.dart';
import 'package:smarthome/board/graphql/mutations/mutations.dart';
import 'package:smarthome/board/graphql/queries/queries.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/graphql_helper.dart';
import 'package:tuple/tuple.dart';

class BoardRepository {
  final GraphQLApiClient graphqlApiClient;

  BoardRepository({required this.graphqlApiClient});

  Future<Comment> addComment({
    required String topicId,
    required String body,
    String? parentId,
  }) async {
    final options = MutationOptions(
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
    final Map<String, dynamic> json = result.data!['addComment'];
    final commentObject = Comment.fromJson(json);
    return commentObject;
  }

  Future<Topic> addTopic({
    required String title,
    required String description,
  }) async {
    final options = MutationOptions(
      document: gql(addTopicMutation),
      variables: {
        'input': {
          'title': title,
          'description': description,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['addTopic'];
    final topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<Topic> closeTopic({required String topicId}) async {
    final options = MutationOptions(
      document: gql(closeTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['closeTopic'];
    final topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<Topic> pinTopic({required String topicId}) async {
    final options = MutationOptions(
      document: gql(pinTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> topicJson = result.data!['pinTopic'];
    final topic = Topic.fromJson(topicJson);
    return topic;
  }

  Future<Topic> unpinTopic({required String topicId}) async {
    final options = MutationOptions(
      document: gql(unpinTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> topicJson = result.data!['unpinTopic'];
    final topic = Topic.fromJson(topicJson);
    return topic;
  }

  Future<String?> deleteComment({required String commentId}) async {
    final options = MutationOptions(
      document: gql(deleteCommentMutation),
      variables: {
        'input': {'commentId': commentId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data!['deleteComment']['id'];
  }

  Future<String?> deleteTopic({required String topicId}) async {
    final options = MutationOptions(
      document: gql(deleteTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data!['deleteTopic']['id'];
  }

  Future<Topic> reopenTopic({required String topicId}) async {
    final options = MutationOptions(
      document: gql(reopenTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['reopenTopic'];
    final topicObject = Topic.fromJson(json);
    return topicObject;
  }

  /// 话题详情的数据
  /// 评论可选择是否按创建时间倒序，默认为正序
  Future<Tuple3<Topic, List<Comment>, PageInfo>> topicDetail({
    required String? topicId,
    bool descending = false,
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(topicDetailQuery),
      variables: {
        'topicId': topicId,
        'order': descending ? 'DESC' : 'ASC',
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo = PageInfo.fromJson(results.data!['comments']['pageInfo']);

    final List<dynamic> commentsJson =
        results.data!.flattenConnection['comments'];
    final comments = commentsJson.map((e) => Comment.fromJson(e)).toList();

    final dynamic topicJson = results.data!.flattenConnection['topic'];
    final topic = Topic.fromJson(topicJson);

    return Tuple3(topic, comments, pageInfo);
  }

  /// 话题列表
  ///
  /// PageInfo
  Future<Tuple2<List<Topic>, PageInfo>> topics({
    String? after,
    bool cache = true,
  }) async {
    final options = QueryOptions(
      document: gql(topicsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final pageInfo = PageInfo.fromJson(results.data!['topics']['pageInfo']);

    final List<dynamic> topicsJson = results.data!.flattenConnection['topics'];
    final topics = topicsJson.map((e) => Topic.fromJson(e)).toList();

    return Tuple2(topics, pageInfo);
  }

  Future<Comment> updateComment({
    required String id,
    required String body,
  }) async {
    final options = MutationOptions(
      document: gql(updateCommentMutation),
      variables: {
        'input': {
          'id': id,
          'body': body,
        }
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data!['updateComment'];
    final commentObject = Comment.fromJson(json);
    return commentObject;
  }

  Future<Topic> updateTopic({
    required String id,
    required String title,
    required String description,
  }) async {
    final options = MutationOptions(
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
    final Map<String, dynamic> json = result.data!['updateTopic'];
    final topicObject = Topic.fromJson(json);
    return topicObject;
  }
}
