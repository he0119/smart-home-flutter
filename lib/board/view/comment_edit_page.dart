import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/view/widgets/comment_item.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class CommentEditPage extends StatefulWidget {
  final bool isEditing;
  final Comment? comment;

  const CommentEditPage({
    Key? key,
    required this.isEditing,
    this.comment,
  }) : super(key: key);

  @override
  _CommentEditPageState createState() => _CommentEditPageState();
}

class _CommentEditPageState extends State<CommentEditPage> {
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _bodyController.text = widget.comment!.body!;
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String>['编辑', '预览'];
    return BlocListener<CommentEditBloc, CommentEditState>(
      listener: (context, state) {
        if (state is CommentAddSuccess || state is CommentUpdateSuccess) {
          Navigator.of(context).pop();
          if (widget.isEditing) {
            showInfoSnackBar('评论编辑成功');
          } else {
            BlocProvider.of<BoardHomeBloc>(context)
                .add(BoardHomeFetched(cache: false));
            showInfoSnackBar('评论添加成功');
          }
        }
        if (state is CommentFailure) {
          showErrorSnackBar(state.message);
        }
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: widget.isEditing ? const Text('编辑评论') : const Text('新评论'),
            actions: [
              Tooltip(
                message: '提交',
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isEditing) {
                        BlocProvider.of<CommentEditBloc>(context)
                            .add(CommentUpdated(
                          id: widget.comment!.id,
                          body: _bodyController.text,
                        ));
                      }
                      showInfoSnackBar('正在提交...', duration: 1);
                    }
                  },
                ),
              )
            ],
            bottom: TabBar(
              tabs: [for (final tab in tabs) Tab(text: tab)],
            ),
          ),
          body: TabBarView(
            children: [
              _EditPage(
                isEditing: widget.isEditing,
                comment: widget.comment,
                formKey: _formKey,
                bodyController: _bodyController,
              ),
              _PreviewPage(
                bodyController: _bodyController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditPage extends StatelessWidget {
  final bool isEditing;
  final Comment? comment;
  final TextEditingController? bodyController;
  final GlobalKey<FormState> formKey;

  const _EditPage({
    Key? key,
    required this.isEditing,
    this.comment,
    this.bodyController,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: bodyController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '想说点什么？',
                  hintStyle: TextStyle(fontSize: 18),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请填写内容';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPage extends StatefulWidget {
  final TextEditingController? bodyController;

  const _PreviewPage({
    Key? key,
    this.bodyController,
  }) : super(key: key);

  @override
  __PreviewPageState createState() => __PreviewPageState();
}

class __PreviewPageState extends State<_PreviewPage> {
  @override
  void initState() {
    super.initState();
    widget.bodyController!.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.bodyController!.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loginUser =
        context.select((AppPreferencesBloc b) => b.state.loginUser);
    return SingleChildScrollView(
      child: CommentItem(
        comment: Comment(
          id: '',
          user: loginUser,
          body: widget.bodyController!.text,
          createdAt: DateTime.now(),
          editedAt: DateTime.now(),
        ),
        showMenu: false,
      ),
    );
  }
}
