import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/view/widgets/comment_item.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/home_page.dart';

class CommentEditPage extends StatefulWidget {
  final bool isEditing;
  final Comment? comment;
  final Topic? topic;

  const CommentEditPage({
    super.key,
    required this.isEditing,
    this.comment,
    this.topic,
  });

  @override
  State<CommentEditPage> createState() => _CommentEditPageState();
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
          if (widget.isEditing) {
            showInfoSnackBar('评论编辑成功');
          } else {
            showInfoSnackBar('评论添加成功');
          }
          // 通知评论列表刷新
          Navigator.of(context).pop(true);
        }
        if (state is CommentFailure) {
          showErrorSnackBar(state.message);
        }
      },
      child: DefaultTabController(
        length: tabs.length,
        child: MySliverScaffold(
          title: widget.isEditing ? const Text('编辑评论') : const Text('新评论'),
          actions: [
            Tooltip(
              message: '提交',
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.isEditing) {
                      context.read<CommentEditBloc>().add(
                            CommentUpdated(
                              id: widget.comment!.id,
                              body: _bodyController.text,
                            ),
                          );
                    } else {
                      context.read<CommentEditBloc>().add(
                            CommentAdded(
                              topicId: widget.topic!.id,
                              body: _bodyController.text,
                            ),
                          );
                    }
                    showInfoSnackBar('正在提交...', duration: 1);
                  }
                },
              ),
            )
          ],
          appbarBottom: TabBar(
            tabs: [for (final tab in tabs) Tab(text: tab)],
          ),
          sliver: SliverFillRemaining(
            child: TabBarView(
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
    required this.isEditing,
    this.comment,
    this.bodyController,
    required this.formKey,
  });

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
    this.bodyController,
  });

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
        context.select((SettingsController settings) => settings.loginUser);
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
