import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 分组标题。全站统一：titleSmall + 次要色，上 24、下 8。
///
/// 右侧可以放一个操作，比如「全部」文字按钮，或者展开 / 收起。
class SectionHeader extends StatelessWidget {
  final String title;

  /// 右侧操作，通常是 TextButton 或 IconButton
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.sm,
      AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// 跳转到另一个页面的入口行：主色圆形图标 + 标题 + 说明 + 尾部箭头。
///
/// 和 [ContentRow] 的区别只有两处：图标用 container 配色强调，
/// 尾巴固定带箭头，让人一眼看出「点进去看更多」。
class EntryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? supporting;
  final VoidCallback? onTap;
  final Widget? trailing;

  const EntryRow({
    super.key,
    required this.icon,
    required this.title,
    this.supporting,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: scheme.primaryContainer,
        child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: supporting == null
          ? null
          : Text(
              supporting!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

/// 内容行：物品、位置、话题、耗材都用它。
///
/// 图标放在浅底圆形里，标题用 bodyLarge，补充信息（时间、位置）放副标题。
class ContentRow extends StatelessWidget {
  final IconData icon;
  final Widget title;

  /// 副标题，字符串或高亮后的文本都行
  final Widget? supporting;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ContentRow({
    super.key,
    required this.icon,
    required this.title,
    this.supporting,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: scheme.surfaceContainerHighest,
        child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      ),
      title: title,
      subtitle: supporting,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// 详情页的「标签 / 值」行：标签小字在上，值在下。
class InfoRow extends StatelessWidget {
  final String label;
  final Widget value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyLarge,
                    child: value,
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// 内容行之间的分隔线。缩进到图标右侧，避免和图标连成一条竖线。
class ContentDivider extends StatelessWidget {
  final double indent;

  const ContentDivider({super.key, this.indent = 72});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: AppSpacing.lg,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

/// 列表底部给 FAB 留出的空白。
class ListBottomPadding extends StatelessWidget {
  final double height;

  const ListBottomPadding({super.key, this.height = 88});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'SectionHeader',
  group: previewGroupWidgets,
  size: Size(400, 200),
)
Widget sectionHeaderPreview() => PreviewFrame(
  width: 400,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SectionHeader(title: '最近添加'),
      SectionHeader(
        title: '全部物品',
        action: TextButton(onPressed: () {}, child: const Text('全部')),
      ),
    ],
  ),
);

@Preview(name: 'EntryRow', group: previewGroupWidgets, size: Size(400, 200))
Widget entryRowPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      EntryRow(icon: Icons.settings_outlined, title: '设置', onTap: () {}),
      EntryRow(
        icon: Icons.info_outline,
        title: '关于',
        supporting: '版本 1.2.3',
        onTap: () {},
      ),
    ],
  ),
);

@Preview(name: 'ContentRow', group: previewGroupWidgets, size: Size(400, 200))
Widget contentRowPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      ContentRow(
        icon: Icons.inbox_outlined,
        title: const Text('电动螺丝刀'),
        supporting: const Text('阳台储物柜 · 3 天前'),
        onTap: () {},
      ),
      ContentRow(
        icon: Icons.inbox_outlined,
        title: const Text('备用电池'),
        trailing: const Text('2 个'),
      ),
    ],
  ),
);

@Preview(name: 'InfoRow', group: previewGroupWidgets, size: Size(400, 200))
Widget infoRowPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      InfoRow(
        label: '存放位置',
        value: const Text('阳台储物柜'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
      const InfoRow(label: '购买日期', value: Text('2026-05-21')),
    ],
  ),
);

@Preview(
  name: 'ContentDivider',
  group: previewGroupWidgets,
  size: Size(400, 240),
)
Widget contentDividerPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      ContentRow(icon: Icons.inbox_outlined, title: const Text('电动螺丝刀')),
      const ContentDivider(),
      ContentRow(icon: Icons.inbox_outlined, title: const Text('备用电池')),
    ],
  ),
);
