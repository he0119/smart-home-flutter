import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

class TopicEditPage extends StatefulWidget {
  final bool isEditing;
  final Topic topic;

  const TopicEditPage({
    Key key,
    @required this.isEditing,
    this.topic,
  }) : super(key: key);

  @override
  _TopicEditPageState createState() => _TopicEditPageState();
}

class _TopicEditPageState extends State<TopicEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => TopicBloc(
            boardRepository: RepositoryProvider.of<BoardRepository>(context)),
        child: BlocConsumer<TopicBloc, TopicState>(
          listener: (context, state) {
            if (state is TopicAddSuccess || state is TopicUpdateSuccess) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: widget.isEditing ? Text('修改话题') : Text('新话题'),
              actions: [
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (widget.isEditing) {
                      BlocProvider.of<TopicBloc>(context).add(TopicUpdated(
                        id: widget.topic.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ));
                    } else {
                      BlocProvider.of<TopicBloc>(context).add(TopicAdded(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ));
                    }
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '添加标题',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '想说点什么？',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
