import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/models/board.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class AddCommentButtonBar extends StatefulWidget {
  final Topic topic;
  final VoidCallback? onAddSuccess;

  AddCommentButtonBar({
    Key? key,
    required this.topic,
    this.onAddSuccess,
  }) : super(key: key);

  @override
  _AddCommentButtonBarState createState() => _AddCommentButtonBarState();
}

class _AddCommentButtonBarState extends State<AddCommentButtonBar> {
  final _formKey = GlobalKey<FormState>();
  final _foucsNode = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foucsNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _foucsNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentEditBloc, CommentEditState>(
      listener: (context, state) {
        if (state is CommentAddSuccess) {
          _controller.text = '';
          _foucsNode.unfocus();
          if (widget.onAddSuccess != null) widget.onAddSuccess!();
          showInfoSnackBar('评论成功');
        }
      },
      child: Material(
        child: ListTile(
          title: Form(
            key: _formKey,
            child: TextFormField(
              enabled: widget.topic.isOpen,
              controller: _controller,
              focusNode: _foucsNode,
              maxLines: null,
              decoration: InputDecoration(hintText: '添加评论'),
              validator: (value) {
                if (_foucsNode.hasFocus && value!.isEmpty) {
                  return '评论不能为空';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          trailing: OutlinedButton(
            onPressed: _foucsNode.hasFocus
                ? () {
                    if (_formKey.currentState!.validate()) {
                      showInfoSnackBar('正在发送...', duration: 1);
                      BlocProvider.of<CommentEditBloc>(context)
                          .add(CommentAdded(
                        topicId: widget.topic.id,
                        body: _controller.text,
                      ));
                    }
                  }
                : null,
            child: Text('发送'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(style: BorderStyle.none),
            ),
          ),
        ),
      ),
    );
  }
}
