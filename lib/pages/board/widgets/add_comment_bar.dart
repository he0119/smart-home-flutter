import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class AddCommentButtonBar extends StatefulWidget {
  final Topic topic;
  final TextEditingController controller;
  final FocusNode focusNode;

  AddCommentButtonBar({
    Key key,
    @required this.topic,
    @required this.controller,
    @required this.focusNode,
  }) : super(key: key);

  @override
  _AddCommentButtonBarState createState() => _AddCommentButtonBarState();
}

class _AddCommentButtonBarState extends State<AddCommentButtonBar> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Form(
        key: _formKey,
        child: TextFormField(
          enabled: widget.topic.isOpen,
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: null,
          decoration: InputDecoration(labelText: '添加评论'),
          validator: (value) {
            if (widget.focusNode.hasFocus && value.isEmpty) {
              return '评论不能为空';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
      trailing: OutlineButton(
        onPressed: widget.focusNode.hasFocus
            ? () {
                if (_formKey.currentState.validate()) {
                  showInfoSnackBar('正在发送...', duration: 1);
                  BlocProvider.of<CommentEditBloc>(context).add(CommentAdded(
                    topicId: widget.topic.id,
                    body: widget.controller.text,
                  ));
                }
              }
            : null,
        borderSide: BorderSide.none,
        child: Text('发送'),
      ),
    );
  }
}
