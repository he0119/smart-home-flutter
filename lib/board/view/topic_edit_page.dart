import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class TopicEditPage extends StatefulWidget {
  final bool isEditing;
  final Topic? topic;

  const TopicEditPage({
    Key? key,
    required this.isEditing,
    this.topic,
  }) : super(key: key);

  @override
  _TopicEditPageState createState() => _TopicEditPageState();
}

class _TopicEditPageState extends State<TopicEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _titleController.text = widget.topic!.title!;
      _descriptionController.text = widget.topic!.description!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String>['编辑', '预览'];
    return BlocListener<TopicEditBloc, TopicEditState>(
      listener: (context, state) {
        if (state is TopicAddSuccess || state is TopicUpdateSuccess) {
          Navigator.of(context).pop();
          if (widget.isEditing) {
            showInfoSnackBar('话题编辑成功');
          } else {
            BlocProvider.of<BoardHomeBloc>(context)
                .add(const BoardHomeFetched(cache: false));
            showInfoSnackBar('话题添加成功');
          }
        }
        if (state is TopicFailure) {
          showErrorSnackBar(state.message);
        }
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: widget.isEditing ? const Text('编辑话题') : const Text('新话题'),
            actions: [
              Tooltip(
                message: '提交',
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isEditing) {
                        BlocProvider.of<TopicEditBloc>(context)
                            .add(TopicUpdated(
                          id: widget.topic!.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                        ));
                      } else {
                        BlocProvider.of<TopicEditBloc>(context).add(TopicAdded(
                          title: _titleController.text,
                          description: _descriptionController.text,
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
                topic: widget.topic,
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
              ),
              _PreviewPage(
                titleController: _titleController,
                descriptionController: _descriptionController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditPage extends StatelessWidget {
  final bool? isEditing;
  final Topic? topic;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;

  const _EditPage({
    Key? key,
    required this.isEditing,
    this.topic,
    required this.titleController,
    required this.descriptionController,
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
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '添加标题',
                  hintStyle: TextStyle(fontSize: 18),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请填写标题';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                controller: descriptionController,
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
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _PreviewPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
  }) : super(key: key);

  @override
  __PreviewPageState createState() => __PreviewPageState();
}

class __PreviewPageState extends State<_PreviewPage> {
  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_onChanged);
    widget.descriptionController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_onChanged);
    widget.descriptionController.removeListener(_onChanged);
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
      child: TopicItem(
        topic: Topic(
          id: '',
          user: loginUser,
          title: widget.titleController.text,
          description: widget.descriptionController.text,
          createdAt: DateTime.now(),
          editedAt: DateTime.now(),
        ),
        showBody: true,
      ),
    );
  }
}
