import 'dart:math' as math;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/constants.dart';

/// [showStoragePicker] 的返回值。
///
/// 单独用一个类而不是直接返回 `Storage?`，是为了区分「点了清空」和
/// 「什么都没选就关掉」：前者要把表单里的值清掉，后者应当保持原值。
@immutable
class StoragePickerResult {
  const StoragePickerResult.selected(Storage this.storage) : cleared = false;

  const StoragePickerResult.cleared() : storage = null, cleared = true;

  /// 选中的位置；[cleared] 为 true 时为 null。
  final Storage? storage;

  /// 用户是否点了「清空」。
  final bool cleared;
}

/// 弹出位置选择器。
///
/// 窄屏（宽度小于 600dp）用底部弹层，宽屏用居中的对话框，两边的
/// 内容是同一个 [StoragePicker]。
Future<StoragePickerResult?> showStoragePicker(
  BuildContext context, {
  Storage? current,
  required List<Storage> storages,
  String title = '选择存放位置',
  bool autofocus = false,
}) {
  final media = MediaQuery.of(context);

  Widget buildPicker(BuildContext pickerContext) {
    return StoragePicker(
      storages: storages,
      current: current,
      title: title,
      autofocus: autofocus,
      onSelected: (Storage storage) => Navigator.of(
        pickerContext,
      ).pop(StoragePickerResult.selected(storage)),
      onCleared: () =>
          Navigator.of(pickerContext).pop(const StoragePickerResult.cleared()),
      onClose: () => Navigator.of(pickerContext).pop(),
    );
  }

  if (media.size.width >= 600) {
    final height = math.min(560.0, media.size.height * 0.82);
    return showDialog<StoragePickerResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          child: SizedBox(
            width: 440,
            height: height,
            child: buildPicker(dialogContext),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<StoragePickerResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final sheetMedia = MediaQuery.of(sheetContext);
      final keyboard = sheetMedia.viewInsets.bottom;
      // 键盘弹起时把弹层顶上去，同时把可用高度让出来，避免内容被挤到溢出
      final height = math.min(
        sheetMedia.size.height * 0.9,
        sheetMedia.size.height - keyboard - 8,
      );
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SizedBox(height: height, child: buildPicker(sheetContext)),
      );
    },
  );
}

/// 位置选择器的内容：标题 + 搜索框 + 列表 + 底部当前值。
///
/// 搜索框为空时按树的层级展示，可以逐级展开；有关键字时把命中的位置
/// 拉平，并在名字下面补一行父级路径，因为这时层级已经被打散了。
class StoragePicker extends StatefulWidget {
  const StoragePicker({
    super.key,
    required this.storages,
    this.current,
    this.title = '选择存放位置',
    this.autofocus = false,
    this.onSelected,
    this.onCleared,
    this.onClose,
  });

  /// 全部位置，父子关系通过 [Storage.parent] 表达。
  final List<Storage> storages;

  /// 当前已选中的位置，用来标记勾选状态并自动展开到它。
  final Storage? current;

  final String title;

  /// 打开后是否立刻聚焦搜索框。
  final bool autofocus;

  final ValueChanged<Storage>? onSelected;
  final VoidCallback? onCleared;
  final VoidCallback? onClose;

  @override
  State<StoragePicker> createState() => _StoragePickerState();
}

class _StoragePickerState extends State<StoragePicker> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _selectedKey = GlobalKey();
  final Set<String> _expanded = <String>{};

  List<_StorageNode> _roots = const <_StorageNode>[];
  String _query = '';
  bool _scrolledToSelected = false;

  @override
  void initState() {
    super.initState();
    _rebuildTree();
    _expandPathTo(widget.current);
    _scrollToSelectedOnce();
  }

  @override
  void didUpdateWidget(covariant StoragePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.storages, widget.storages)) {
      _rebuildTree();
      _expandPathTo(widget.current);
    } else if (oldWidget.current != widget.current) {
      _expandPathTo(widget.current);
      _scrolledToSelected = false;
      _scrollToSelectedOnce();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(Storage storage) =>
      widget.current != null && widget.current!.id == storage.id;

  /// 把扁平的位置列表搭成树。根节点固定是「家」，这样才能选到根。
  void _rebuildTree() {
    final ids = widget.storages.map((Storage storage) => storage.id).toSet();
    final byParent = <String, List<Storage>>{};
    for (final storage in widget.storages) {
      var parentId = storage.parent?.id ?? homeStorage.id;
      // 父级没有一起返回时挂到根上，免得整棵子树凭空消失
      if (parentId != homeStorage.id && !ids.contains(parentId)) {
        parentId = homeStorage.id;
      }
      byParent.putIfAbsent(parentId, () => <Storage>[]).add(storage);
    }

    final visiting = <String>{};
    _StorageNode? build(Storage storage, String parentPath) {
      if (!visiting.add(storage.id)) {
        return null; // 数据里有环时直接跳过，避免无限递归
      }
      final path = parentPath.isEmpty
          ? storage.name
          : '$parentPath / ${storage.name}';
      final children = <_StorageNode>[];
      for (final child in byParent[storage.id] ?? const <Storage>[]) {
        final node = build(child, path);
        if (node != null) {
          children.add(node);
        }
      }
      return _StorageNode(
        storage: storage,
        path: path,
        parentPath: parentPath,
        children: List<_StorageNode>.unmodifiable(children),
      );
    }

    _roots = <_StorageNode>[
      build(homeStorage, '') ?? _StorageNode(storage: homeStorage, path: '家'),
    ];
    _expanded.add(homeStorage.id);
  }

  /// 展开当前选中项的所有上级，否则进入弹窗后看不到它。
  void _expandPathTo(Storage? storage) {
    if (storage == null) {
      return;
    }

    bool walk(_StorageNode node, List<String> ancestors) {
      if (node.storage.id == storage.id) {
        _expanded.addAll(ancestors);
        _expanded.add(node.storage.id);
        return true;
      }
      final next = <String>[...ancestors, node.storage.id];
      for (final child in node.children) {
        if (walk(child, next)) {
          return true;
        }
      }
      return false;
    }

    for (final root in _roots) {
      if (walk(root, const <String>[])) {
        break;
      }
    }
  }

  void _scrollToSelectedOnce() {
    if (_scrolledToSelected || widget.current == null) {
      return;
    }
    _scrolledToSelected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _selectedKey.currentContext;
      if (target == null || !mounted) {
        return;
      }
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _toggle(String id) {
    setState(() {
      if (!_expanded.remove(id)) {
        _expanded.add(id);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<_StorageNode> get _matches {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return const <_StorageNode>[];
    }
    final matches = <_StorageNode>[];
    void walk(_StorageNode node) {
      if (node.storage.name.toLowerCase().contains(query)) {
        matches.add(node);
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final root in _roots) {
      walk(root);
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final searching = _query.trim().isNotEmpty;
    final matches = searching ? _matches : const <_StorageNode>[];

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SearchBar(
            controller: _searchController,
            autoFocus: widget.autofocus,
            hintText: '搜索位置名称',
            leading: const Icon(Icons.search, size: 20),
            trailing: <Widget>[
              if (_query.isNotEmpty)
                IconButton(
                  tooltip: '清除搜索',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
            elevation: const WidgetStatePropertyAll<double>(0),
            backgroundColor: WidgetStatePropertyAll<Color>(
              colors.surfaceContainerHigh,
            ),
            constraints: const BoxConstraints(minHeight: 52),
            padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (String value) => setState(() => _query = value),
            onSubmitted: (_) => _clearFocus(),
          ),
        ),
        if (searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                matches.isEmpty ? '没有匹配的位置' : '共 ${matches.length} 个结果',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        Expanded(child: searching ? _buildSearchResult(matches) : _buildTree()),
        _buildFooter(theme),
      ],
    );
  }

  void _clearFocus() {
    FocusScope.of(context).unfocus();
  }

  Widget _buildTree() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[for (final root in _roots) _buildNode(root, 0)],
      ),
    );
  }

  Widget _buildNode(_StorageNode node, int depth) {
    final selected = _isSelected(node.storage);
    final hasChildren = node.children.isNotEmpty;
    final expanded = _expanded.contains(node.storage.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _StorageTile(
          key: selected ? _selectedKey : null,
          storage: node.storage,
          depth: depth,
          selected: selected,
          path: node.path,
          hasChildren: hasChildren,
          expanded: expanded,
          onTap: () => widget.onSelected?.call(node.storage),
          onToggle: hasChildren ? () => _toggle(node.storage.id) : null,
        ),
        if (hasChildren)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final child in node.children)
                          _buildNode(child, depth + 1),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResult(List<_StorageNode> matches) {
    if (matches.isEmpty) {
      return _EmptySearch(query: _query.trim(), onClear: _clearSearch);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      itemCount: matches.length,
      itemBuilder: (BuildContext context, int index) {
        final node = matches[index];
        return _StorageTile(
          storage: node.storage,
          depth: 0,
          selected: _isSelected(node.storage),
          path: node.path,
          subtitle: node.parentPath,
          showPath: true,
          highlight: _query.trim(),
          onTap: () => widget.onSelected?.call(node.storage),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final colors = theme.colorScheme;
    final current = widget.current;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              current == null ? '未选择位置' : '当前：${_pathOf(current)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (current != null)
            TextButton(onPressed: widget.onCleared, child: const Text('清空')),
        ],
      ),
    );
  }

  String _pathOf(Storage storage) {
    String? found;
    void walk(_StorageNode node) {
      if (found != null) {
        return;
      }
      if (node.storage.id == storage.id) {
        found = node.path;
        return;
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final root in _roots) {
      walk(root);
    }
    return found ?? storage.name;
  }
}

/// 把一棵位置树拍成列表里的一行，同时记住完整路径方便展示和辅助朗读。
class _StorageNode {
  const _StorageNode({
    required this.storage,
    required this.path,
    this.parentPath = '',
    this.children = const <_StorageNode>[],
  });

  final Storage storage;

  /// 含自己的完整路径，例如「家 / 阳台 / 阳台储物柜」。
  final String path;

  /// 只到父级的路径，搜索结果里当副标题用，避免把名字念两遍。
  final String parentPath;

  final List<_StorageNode> children;
}

class _StorageTile extends StatelessWidget {
  const _StorageTile({
    super.key,
    required this.storage,
    required this.depth,
    required this.selected,
    required this.path,
    this.subtitle = '',
    this.showPath = false,
    this.highlight = '',
    this.hasChildren = false,
    this.expanded = false,
    this.onTap,
    this.onToggle,
  });

  final Storage storage;
  final int depth;
  final bool selected;
  final String path;
  final String subtitle;
  final bool showPath;
  final String highlight;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = selected
        ? colors.onSecondaryContainer
        : colors.onSurface;
    final iconColor = selected ? colors.primary : colors.onSurfaceVariant;
    final semanticLabel = showPath ? path.replaceAll(' / ', '，') : storage.name;

    return Padding(
      padding: EdgeInsets.only(
        left: 8 + depth * 24.0,
        right: 8,
        top: 1,
        bottom: 1,
      ),
      child: Semantics(
        button: true,
        selected: selected,
        expanded: hasChildren ? expanded : null,
        label: semanticLabel,
        onTap: onTap,
        onExpand: hasChildren && !expanded ? onToggle : null,
        onCollapse: hasChildren && expanded ? onToggle : null,
        child: ExcludeSemantics(
          child: Material(
            color: selected ? colors.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey<String>('storage-picker-row-${storage.id}'),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: <Widget>[
                    // 搜索结果没有层级，不需要展开箭头的位置
                    if (showPath)
                      const SizedBox(width: 8)
                    else
                      SizedBox(
                        width: 40,
                        height: 48,
                        child: hasChildren
                            ? GestureDetector(
                                key: ValueKey<String>(
                                  'storage-picker-expand-${storage.id}',
                                ),
                                behavior: HitTestBehavior.opaque,
                                onTap: onToggle,
                                child: Center(
                                  child: AnimatedRotation(
                                    turns: expanded ? 0 : -0.25,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    child: Icon(
                                      Icons.expand_more,
                                      size: 20,
                                      color: iconColor,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    Icon(Icons.folder_outlined, size: 18, color: iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildName(theme, foreground, colors),
                          if (showPath && subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? colors.onSecondaryContainer.withValues(
                                        alpha: 0.75,
                                      )
                                    : colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: selected
                          ? Icon(
                              Icons.check_circle,
                              size: 20,
                              color: colors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildName(ThemeData theme, Color color, ColorScheme colors) {
    final style = theme.textTheme.bodyLarge?.copyWith(
      color: color,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    );
    final query = highlight.trim().toLowerCase();
    final index = query.isEmpty
        ? -1
        : storage.name.toLowerCase().indexOf(query);
    if (index < 0) {
      return Text(
        storage.name,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: storage.name.substring(0, index)),
          TextSpan(
            text: storage.name.substring(index, index + query.length),
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: storage.name.substring(index + query.length)),
        ],
      ),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off, size: 40, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('没有找到「$query」', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '换个名字试试，或者清空搜索浏览全部位置',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onClear, child: const Text('清空搜索')),
          ],
        ),
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'StoragePicker')
Widget storagePickerPreview() {
  const balcony = Storage(id: 'balcony', name: '阳台', parent: homeStorage);
  const cabinet = Storage(id: 'cabinet', name: '阳台储物柜', parent: balcony);
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      useMaterial3: true,
    ),
    home: Scaffold(
      body: StoragePicker(
        storages: const <Storage>[
          balcony,
          cabinet,
          Storage(id: 'toolbox', name: '工具箱', parent: balcony),
          Storage(id: 'toolbox-2', name: '工具箱2', parent: balcony),
          Storage(id: 'box-123', name: '123'),
          Storage(
            id: 'box-1231',
            name: '1231',
            parent: Storage(id: 'box-123', name: '123'),
          ),
          Storage(id: 'box-23123', name: '23123'),
        ],
        current: cabinet,
      ),
    ),
  );
}
