import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/widgets/item_row.dart';
import 'package:smarthome/storage/view/widgets/scan_qr_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/state_views.dart';

class StorageHomePage extends StatelessWidget {
  const StorageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageHomeScreen();
  }
}

class StorageHomeScreen extends ConsumerStatefulWidget {
  const StorageHomeScreen({super.key});

  @override
  ConsumerState<StorageHomeScreen> createState() => _StorageHomeScreenState();
}

class _StorageHomeScreenState extends ConsumerState<StorageHomeScreen> {
  /// 收起的分组。收起只是隐藏行，不去重新请求数据，
  /// 这样点箭头时列表不会整页闪一下、也不会跳回顶部。
  final Set<ItemType> _collapsed = <ItemType>{};

  static const Duration _collapseDuration = Duration(milliseconds: 240);

  void _toggleSection(ItemType type) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_collapsed.remove(type)) {
        _collapsed.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storageHomeProvider);
    return MyHomePage(
      title: AppTab.storage.name,
      actions: <Widget>[
        // 仅支持网页和安卓
        if (kIsWeb || Platform.isAndroid) const ScanQRIconButton(),
        const SearchIconButton(),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: '添加物品',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ItemEditPage(isEditing: false),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      slivers: _buildSlivers(state),
      onRefresh: (state.status == StorageHomeStatus.success)
          ? () async {
              await ref
                  .read(storageHomeProvider.notifier)
                  .fetch(itemType: state.itemType, cache: false);
            }
          : null,
    );
  }

  List<Widget> _buildSlivers(StorageHomeState state) {
    final slivers = <Widget>[];

    if (state.status == StorageHomeStatus.failure) {
      slivers.add(
        SliverErrorState(
          onRetry: () {
            ref
                .read(storageHomeProvider.notifier)
                .fetch(itemType: state.itemType, cache: false);
          },
          message: state.errorMessage,
        ),
      );
      return slivers;
    }

    if (state.status == StorageHomeStatus.loading) {
      slivers.add(const SliverCenterLoadingIndicator());
      return slivers;
    }

    if (state.status != StorageHomeStatus.success) {
      return slivers;
    }

    slivers.add(
      SliverToBoxAdapter(
        child: EntryRow(
          icon: Icons.storage,
          title: '所有位置',
          supporting: '全部位置和物品',
          onTap: () {
            context.goStorageDetail(homeStorage.id);
          },
        ),
      ),
    );

    final sections = <_HomeSection>[
      _HomeSection(type: ItemType.expired, items: state.expiredItems),
      _HomeSection(type: ItemType.nearExpired, items: state.nearExpiredItems),
      _HomeSection(
        type: ItemType.recentlyEdited,
        items: state.recentlyEditedItems,
      ),
      _HomeSection(
        type: ItemType.recentlyCreated,
        items: state.recentlyCreatedItems,
      ),
    ];

    final visibleSections = sections
        .where((section) => section.items?.isNotEmpty ?? false)
        .toList();

    if (visibleSections.isEmpty) {
      slivers.add(
        const SliverEmptyState(
          icon: Icons.inventory_2_outlined,
          title: '还没有物品',
          message: '点右下角的 + 添加第一个物品',
        ),
      );
    } else {
      for (final section in visibleSections) {
        slivers.add(
          SliverToBoxAdapter(
            child: _SectionBlock(
              title: section.type.sectionTitle,
              count: section.items?.length ?? 0,
              collapsed: _collapsed.contains(section.type),
              duration: _collapseDuration,
              onToggle: () => _toggleSection(section.type),
              onShowAll: () => context.goItemTypeItems(section.type),
              // 内容始终按原尺寸排好，只改变露出来的高度：收起时行是往上滑走、
              // 被裁掉，而不是整块瞬间消失留一片空白
              body: _buildSectionBody(section),
            ),
          ),
        );
      }
    }

    slivers.add(const SliverToBoxAdapter(child: ListBottomPadding()));
    return slivers;
  }

  Widget _buildSectionBody(_HomeSection section) {
    final items = section.items ?? const <Item>[];
    return Column(
      children: <Widget>[
        for (var i = 0; i < items.length; i++) ...<Widget>[
          ItemRow(item: items[i], type: section.type),
          if (i < items.length - 1) const ContentDivider(),
        ],
      ],
    );
  }
}

class _HomeSection {
  final ItemType type;
  final List<Item>? items;

  const _HomeSection({required this.type, required this.items});
}

/// 分组标题：整行都能点，箭头跟着转；固定在顶部，滚动时不会跑掉。
class _SectionHeaderBar extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onShowAll;

  const _SectionHeaderBar({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.duration,
    required this.onTap,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          expanded: !collapsed,
          label: '$title，$count 个物品',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // 首页每个分组只显示第一页，想看这一类全部就走这里
                Tooltip(
                  message: '查看全部$title',
                  child: TextButton(
                    onPressed: onShowAll,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(48, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                    ),
                    child: const Text('全部'),
                  ),
                ),
                AnimatedRotation(
                  turns: collapsed ? -0.25 : 0,
                  duration: duration,
                  curve: Curves.easeInOutCubic,
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 一个分组：标题 + 可以卷起放下的内容。
class _SectionBlock extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final Duration duration;
  final VoidCallback onToggle;
  final VoidCallback onShowAll;
  final Widget body;

  const _SectionBlock({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.duration,
    required this.onToggle,
    required this.onShowAll,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          // 48 高保证整行都是能点中的区域，不受文字高度影响
          child: SizedBox(
            height: 48,
            child: _SectionHeaderBar(
              title: title,
              count: count,
              collapsed: collapsed,
              duration: duration,
              onTap: onToggle,
              onShowAll: onShowAll,
            ),
          ),
        ),
        // 收起后内容只是被裁掉，读屏仍然会念到，所以要把语义一起排除
        ExcludeSemantics(
          excluding: collapsed,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: collapsed ? 0 : 1),
            duration: duration,
            curve: Curves.easeInOutCubic,
            builder: (context, factor, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: factor,
                  child: child,
                ),
              );
            },
            child: body,
          ),
        ),
      ],
    );
  }
}
