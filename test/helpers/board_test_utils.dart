import 'package:smarthome/board/model/board.dart';

Topic buildTopic({String id = 'topic-1', List<Comment>? comments}) =>
    Topic(id: id, title: 'Topic $id', comments: comments);

Comment buildComment({String id = 'comment-1', Topic? topic}) =>
    Comment(id: id, topic: topic, body: 'Comment $id');
