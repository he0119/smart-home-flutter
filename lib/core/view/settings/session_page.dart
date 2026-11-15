import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/user/providers/session_provider.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/state_views.dart';

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
            if (state.sessions.isEmpty) {
              return const SliverEmptyState(
                icon: Icons.devices_outlined,
                title: '没有其它登录设备',
                message: '在别的设备上登录后，这里会显示最近活跃时间',
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final session = state.sessions[index];
                return Column(
                  children: <Widget>[
                    ContentRow(
                      icon: Icons.devices_outlined,
                      title: Text(
                        session.isCurrent ? '${session.ip}（当前设备）' : session.ip,
                      ),
                      supporting: Text(
                        '最近活跃：${session.lastActivity.toLocalShortStr()}',
                      ),
                      trailing: session.isCurrent
                          ? null
                          : IconButton(
                              tooltip: '删除会话',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: '删除这个登录设备',
                                  message: '删除后该设备需要重新登录',
                                  confirmLabel: '删除',
                                  destructive: true,
                                );
                                if (!confirmed) {
                                  return;
                                }
                                await ref
                                    .read(sessionProvider.notifier)
                                    .deleteSession(session.id);
                              },
                            ),
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('设备详情'),
                            content: Column(
                              mainAxisSize: .min,
                              children: <Widget>[
                                InfoRow(label: 'IP', value: Text(session.ip)),
                                InfoRow(
                                  label: '最近活跃',
                                  value: Text(
                                    session.lastActivity.toLocalShortStr(),
                                  ),
                                ),
                                InfoRow(
                                  label: '用户代理',
                                  value: Text(session.userAgent),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('关闭'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (index < state.sessions.length - 1)
                      const ContentDivider(),
                  ],
                );
              }, childCount: state.sessions.length),
            );
          }
          if (state is SessionFailure) {
            return SliverErrorState(
              message: state.message,
              onRetry: () {
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
