import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/user/providers/session_provider.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';

class SessionPage extends ConsumerWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    return MySliverScaffold(
      title: const Text('登录设备'),
      sliver: Builder(
        builder: (context) {
          if (state is SessionSuccess) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final session = state.sessions[index];
                return ListTile(
                  title: Text(
                    session.ip + (session.isCurrent ? ' (当前设备)' : ''),
                  ),
                  subtitle: Text('最近活跃：${session.lastActivity.toLocalStr()}'),
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(session.ip),
                          content: Text(
                            '最近活跃：${session.lastActivity.toLocalStr()}\n用户代理：${session.userAgent}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('确认'),
                            ),
                          ],
                        );
                      },
                    ),
                  },
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
                                      ref
                                          .read(sessionProvider.notifier)
                                          .deleteSession(session.id);
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
              }, childCount: state.sessions.length),
            );
          }
          if (state is SessionFailure) {
            return SliverErrorMessageButton(
              message: state.message,
              onPressed: () {
                ref.read(sessionProvider.notifier).fetchSessions();
              },
            );
          }
          return const SliverCenterLoadingIndicator();
        },
      ),
    );
  }
}
