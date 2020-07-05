import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/mutations/board/mutations.dart';
import 'package:smart_home/graphql/queries/board/queries.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class BoardRepository {
  final GraphQLApiClient graphqlApiClient;

  BoardRepository({@required this.graphqlApiClient});

  Future<Comment> addComment({
    @required String topicId,
    @required String body,
    String parentId,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(addCommentMutation),
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
      documentNode: gql(addTopicMutation),
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
      documentNode: gql(closeTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['closeTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<List<Comment>> comments({
    @required String topicId,
    int number,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(commentsQuery),
      variables: {
        'topicId': topicId,
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> comments = results.data['comments'];
    final List<Comment> listofComments =
        comments.map((dynamic e) => Comment.fromJson(e)).toList();
    return listofComments;
  }

  Future<String> deleteComment({@required String commentId}) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(deleteCommentMutation),
      variables: {
        'input': {'commentId': commentId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data['deleteComment']['commentId'];
  }

  Future<String> deleteTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(deleteTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    return result.data['deleteTopic']['topicId'];
  }

  Future<Topic> reopenTopic({@required String topicId}) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(reopenTopicMutation),
      variables: {
        'input': {'topicId': topicId}
      },
    );
    final result = await graphqlApiClient.mutate(options);
    final Map<String, dynamic> json = result.data['reopenTopic']['topic'];
    final Topic topicObject = Topic.fromJson(json);
    return topicObject;
  }

  Future<List<dynamic>> topicDetail({
    @required String topicId,
    int number,
    bool cache = true,
  }) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(topicDetailQuery),
      variables: {
        'topicId': topicId,
        'number': number,
      },
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final dynamic topic = results.data['topic'];
    final Topic topicObject = Topic.fromJson(topic);
    final List<dynamic> comments = results.data['comments'];
    final List<Comment> listofComments =
        comments.map((dynamic e) => Comment.fromJson(e)).toList();
    return [topicObject, listofComments];
  }

  Future<List<Topic>> topics({int number, bool cache = true}) async {
    final QueryOptions options = QueryOptions(
      documentNode: gql(topicsQuery),
      variables: {'number': number},
      fetchPolicy: cache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> topics = results.data['topics'];
    final List<Topic> listofTopics =
        topics.map((dynamic e) => Topic.fromJson(e)).toList();
    return listofTopics;
  }

  Future<Comment> updateComment({
    @required String id,
    String body,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateCommentMutation),
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
    String title,
    String description,
  }) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(updateTopicMutation),
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
