import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/user/bloc/bloc/session_bloc.dart';
import 'package:smarthome/utils/date_format_extension.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录设备'),
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SessionSuccess) {
            return ListView.builder(
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                return ListTile(
                  title:
                      Text(session.ip + (session.isCurrent ? ' (当前设备)' : '')),
                  subtitle: Text('最近活跃：${session.lastActivity.toLocalStr()}'),
                  trailing: session.isCurrent
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('确定要删除吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<SessionBloc>()
                                          .add(SessionDeleted(session.id));
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                );
              },
            );
          }
          if (state is SessionFailure) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
