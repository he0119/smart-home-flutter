import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class AddCommentButtonBar extends StatefulWidget {
  final Topic topic;

  AddCommentButtonBar({Key key, @required this.topic}) : super(key: key);

  @override
  _AddCommentButtonBarState createState() => _AddCommentButtonBarState();
}

class _AddCommentButtonBarState extends State<AddCommentButtonBar> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = new FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentEditBloc, CommentEditState>(
      listener: (context, state) {
        // TODO: 更自然的刷新方法
        if (state is CommentAddSuccess) {
          BlocProvider.of<TopicDetailBloc>(context)
              .add(TopicDetailRefreshed(topicId: widget.topic.id));
        }
      },
      child: Material(
        child: ListTile(
          title: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              decoration: InputDecoration(labelText: '添加评论'),
              validator: (value) {
                if (_focusNode.hasFocus && value.isEmpty) {
                  return '评论不能为空';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          trailing: OutlineButton(
            onPressed: _focusNode.hasFocus
                ? () {
                    if (_formKey.currentState.validate()) {
                      showInfoSnackBar('正在发送...', duration: 1);
                      BlocProvider.of<CommentEditBloc>(context)
                          .add(CommentAdded(
                        topicId: widget.topic.id,
                        body: _controller.text,
                      ));
                    }
                  }
                : null,
            borderSide: BorderSide.none,
            child: Text('发送'),
          ),
        ),
      ),
    );
  }
}
