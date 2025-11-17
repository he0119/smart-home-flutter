import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/topic_edit_provider.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/home_page.dart';

class TopicEditPage extends ConsumerStatefulWidget {
  final bool isEditing;
  final Topic? topic;

  const TopicEditPage({super.key, required this.isEditing, this.topic});

  @override
  ConsumerState<TopicEditPage> createState() => _TopicEditPageState();
}

class _TopicEditPageState extends ConsumerState<TopicEditPage> {
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

    ref.listen<TopicEditState>(topicEditProvider, (previous, next) {
      if (next.status == TopicEditStatus.addSuccess ||
          next.status == TopicEditStatus.updateSuccess) {
        if (widget.isEditing) {
          showInfoSnackBar('话题编辑成功');
        } else {
          showInfoSnackBar('话题添加成功');
        }
        Navigator.of(context).pop(true);
      }
      if (next.status == TopicEditStatus.failure) {
        showErrorSnackBar(next.errorMessage);
      }
    });

    return DefaultTabController(
      length: tabs.length,
      child: MySliverScaffold(
        title: widget.isEditing ? const Text('编辑话题') : const Text('新话题'),
        actions: [
          Tooltip(
            message: '提交',
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (widget.isEditing) {
                    ref
                        .read(topicEditProvider.notifier)
                        .updateTopic(
                          id: widget.topic!.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                        );
                  } else {
                    ref
                        .read(topicEditProvider.notifier)
                        .addTopic(
                          title: _titleController.text,
                          description: _descriptionController.text,
                        );
                  }
                  showInfoSnackBar('正在提交...', duration: 1);
                }
              },
            ),
          ),
        ],
        appbarBottom: TabBar(tabs: [for (final tab in tabs) Tab(text: tab)]),
        sliver: SliverFillRemaining(
          child: TabBarView(
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
    required this.isEditing,
    this.topic,
    required this.titleController,
    required this.descriptionController,
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
    required this.titleController,
    required this.descriptionController,
  });

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
    final loginUser = context.select<SettingsController, User?>(
      (settings) => settings.loginUser,
    );
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
