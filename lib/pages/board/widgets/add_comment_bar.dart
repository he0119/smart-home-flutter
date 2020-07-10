import 'package:flutter/material.dart';

class AddCommentButtonBar extends StatefulWidget {
  AddCommentButtonBar({Key key}) : super(key: key);

  @override
  _AddCommentButtonBarState createState() => _AddCommentButtonBarState();
}

class _AddCommentButtonBarState extends State<AddCommentButtonBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        title: TextField(
          maxLines: null,
          decoration: InputDecoration(labelText: '添加评论'),
        ),
        trailing: OutlineButton(
          onPressed: () {},
          borderSide: BorderSide.none,
          child: Text('发送'),
        ),
      ),
    );
  }
}
