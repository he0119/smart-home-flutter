import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/board.dart';

class AddCommentButtonBar extends StatefulWidget {
  final Topic topic;

  AddCommentButtonBar({Key key, @required this.topic}) : super(key: key);

  @override
  _AddCommentButtonBarState createState() => _AddCommentButtonBarState();
}

class _AddCommentButtonBarState extends State<AddCommentButtonBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        // TODO: 更自然的刷新方法
        if (state is CommentAddSuccess) {
          BlocProvider.of<TopicDetailBloc>(context)
              .add(TopicDetailRefreshed(topicId: widget.topic.id));
        }
      },
      child: Material(
        child: ListTile(
          title: TextField(
            controller: _controller,
            maxLines: null,
            decoration: InputDecoration(labelText: '添加评论'),
          ),
          trailing: OutlineButton(
            onPressed: () {
              // TODO: 单击发送之后添加提示正在发送
              BlocProvider.of<CommentBloc>(context).add(CommentAdded(
                topicId: widget.topic.id,
                body: _controller.text,
              ));
            },
            borderSide: BorderSide.none,
            child: Text('发送'),
          ),
        ),
      ),
    );
  }
}
