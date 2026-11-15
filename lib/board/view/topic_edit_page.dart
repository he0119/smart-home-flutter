import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/topic_edit_provider.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
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

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      showErrorSnackBar('请填写标题');
      return;
    }
    if (description.isEmpty) {
      showErrorSnackBar('请填写内容');
      return;
    }
    // 在「编辑」tab 时顺带亮行内校验；在「预览」tab 时 Form 已被销毁，
    // 这里用 currentState? 而不是 !，避免切到预览后点发送直接崩
    _formKey.currentState?.validate();

    if (widget.isEditing) {
      ref
          .read(topicEditProvider.notifier)
          .updateTopic(
            id: widget.topic!.id,
            title: title,
            description: description,
          );
    } else {
      ref
          .read(topicEditProvider.notifier)
          .addTopic(title: title, description: description);
    }
    showInfoSnackBar('正在提交...', duration: 1);
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

    final submitting =
        ref.watch(topicEditProvider).status == TopicEditStatus.loading;

    return DefaultTabController(
      length: tabs.length,
      child: MySliverScaffold(
        appBarSize: AppBarSize.normal,
        title: widget.isEditing ? const Text('编辑话题') : const Text('新话题'),
        actions: [
          IconButton(
            tooltip: '发布',
            icon: const Icon(Icons.send),
            onPressed: submitting ? null : _submit,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            spacing: AppSpacing.md,
            children: [
              TextFormField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '一句话说清话题',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请填写标题';
                  }
                  return null;
                },
                autovalidateMode: .onUserInteraction,
              ),
              TextFormField(
                controller: descriptionController,
                minLines: 8,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '想说点什么？',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请填写内容';
                  }
                  return null;
                },
                autovalidateMode: .onUserInteraction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPage extends ConsumerStatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _PreviewPage({
    required this.titleController,
    required this.descriptionController,
  });

  @override
  __PreviewPageState createState() => __PreviewPageState();
}

class __PreviewPageState extends ConsumerState<_PreviewPage> {
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
    final settings = ref.watch(settingsProvider);
    final loginUser = settings.loginUser;
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
