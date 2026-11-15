import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 空状态：图标 + 标题 + 说明 + 可选操作。
///
/// 之前页面里只有一行居中的文字，用户看不出「是真的没有」还是「还没加载」。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: icon,
      title: title,
      message: message,
      action: action,
      iconBackground: Theme.of(context).colorScheme.surfaceContainerHighest,
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

/// 加载失败：图标 + 标题 + 错误信息 + 重试。
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = '加载失败',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _StateLayout(
      icon: Icons.cloud_off_outlined,
      title: title,
      message: message,
      iconBackground: colors.errorContainer,
      iconColor: colors.onErrorContainer,
      action: onRetry == null
          ? null
          : FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
    );
  }
}

/// 加载中：转圈 + 一句说明，读屏也能念出来。
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: <Widget>[
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// [EmptyState] 的 sliver 版本，铺满剩余空间并居中。
class SliverEmptyState extends StatelessWidget {
  const SliverEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyState(
        title: title,
        message: message,
        icon: icon,
        action: action,
      ),
    );
  }
}

/// [ErrorState] 的 sliver 版本。
class SliverErrorState extends StatelessWidget {
  const SliverErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = '加载失败',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorState(message: message, onRetry: onRetry, title: title),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    required this.iconBackground,
    required this.iconColor,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: .min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: .circle,
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: .center,
              ),
              if (message != null && message!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: .center,
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'EmptyState', group: previewGroupWidgets, size: Size(400, 400))
Widget emptyStatePreview() => PreviewFrame(
  child: EmptyState(
    title: '还没有物品',
    message: '点右下角的加号添加第一件',
    action: FilledButton.tonal(onPressed: () {}, child: const Text('去添加')),
  ),
);

@Preview(name: 'ErrorState', group: previewGroupWidgets, size: Size(400, 400))
Widget errorStatePreview() => PreviewFrame(
  child: ErrorState(message: '网络连接超时', onRetry: () {}),
);

@Preview(name: 'LoadingState', group: previewGroupWidgets, size: Size(400, 240))
Widget loadingStatePreview() =>
    PreviewFrame(child: const LoadingState(message: '正在加载物品'));

@Preview(
  name: 'SliverEmptyState',
  group: previewGroupWidgets,
  size: Size(400, 400),
)
Widget sliverEmptyStatePreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: const CustomScrollView(
    slivers: <Widget>[
      SliverEmptyState(title: '还没有物品', message: '点右下角的加号添加第一件'),
    ],
  ),
);

@Preview(
  name: 'SliverErrorState',
  group: previewGroupWidgets,
  size: Size(400, 400),
)
Widget sliverErrorStatePreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: CustomScrollView(
    slivers: <Widget>[SliverErrorState(message: '网络连接超时', onRetry: () {})],
  ),
);
