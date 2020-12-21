import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:smart_home/graphql/mutations/board/mutations.dart';
import 'package:smart_home/graphql/queries/board/queries.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
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

  Future<Tuple2<Topic, List<Comment>>> topicDetail({
    @required String topicId,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(topicDetailQuery),
      variables: {
        'topicId': topicId,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final dynamic topicJson = results.data['topic'];
    final Topic topic = Topic.fromJson(topicJson);

    final List<dynamic> commentsJson = results.data['comments']['edges'];
    final List<Comment> comments = commentsJson.map((dynamic e) {
      List<dynamic> children = e['node']['children']['edges'];
      if (children.isNotEmpty) {
        final newchildren = children.map((dynamic e) => e['node']).toList();
        e['node']['children'] = newchildren;
      } else {
        e['node']['children'] = [];
      }
      return Comment.fromJson(e['node']);
    }).toList();
    return Tuple2(topic, comments);
  }

  Future<List<Topic>> topics({String after, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      document: gql(topicsQuery),
      variables: {
        'after': after,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);

    final List<dynamic> topics = results.data['topics']['edges'];
    final List<Topic> listofTopics =
        topics.map((dynamic e) => Topic.fromJson(e['node'])).toList();
    return listofTopics;
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
