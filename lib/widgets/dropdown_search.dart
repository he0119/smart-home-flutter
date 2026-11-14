import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// 按关键字加载候选项的回调。关键字为空时返回全部候选项。
typedef DropdownItemsLoader<T> = Future<List<T>> Function(String text);

/// 带搜索框的单选下拉框。
///
/// 候选项不是本地过滤，而是每次输入都通过 [items] 重新请求（服务端搜索），
/// 所以适合候选量大、需要按关键字查后端的场景。
class MyDropdownSearch<T> extends StatefulWidget {
  /// 输入框上方的标签。
  final String? label;

  /// 候选项加载器，输入变化时调用。
  final DropdownItemsLoader<T>? items;

  /// 选中项变化时调用，清除选择时传 null。
  final ValueChanged<T?>? onSelected;

  /// 初始选中项。
  final T? selectedItem;

  /// 是否在已选中时显示清除按钮。
  final bool showClearButton;

  /// 校验函数，和 [FormField.validator] 用法一致。
  final String? Function(T?)? validator;

  /// 校验时机，和 [FormField.autovalidateMode] 用法一致。
  final AutovalidateMode autoValidateMode;

  const MyDropdownSearch({
    super.key,
    this.label,
    this.items,
    this.onSelected,
    this.selectedItem,
    this.showClearButton = false,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
  });

  @override
  State<MyDropdownSearch<T>> createState() => _MyDropdownSearchState<T>();
}

class _MyDropdownSearchState<T> extends State<MyDropdownSearch<T>> {
  late final TextEditingController _controller;
  T? _value;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _value = widget.selectedItem;
    _controller = TextEditingController(text: _displayText(_value));
  }

  @override
  void didUpdateWidget(covariant MyDropdownSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部改了选中项时同步显示
    if (widget.selectedItem != oldWidget.selectedItem) {
      _value = widget.selectedItem;
      _controller.text = _displayText(_value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _displayText(T? value) => value?.toString() ?? '';

  Future<void> _openPicker() async {
    final loader = widget.items;
    if (loader == null) {
      return;
    }
    // 先收起键盘，否则弹窗的搜索框会被挡住
    FocusScope.of(context).unfocus();
    final selected = await showDialog<T>(
      context: context,
      builder: (BuildContext context) =>
          _DropdownSearchDialog<T>(loader: loader, selected: _value),
    );
    if (!mounted || selected == null) {
      return;
    }
    _updateValue(selected);
  }

  void _updateValue(T? value) {
    setState(() {
      _value = value;
      _controller.text = _displayText(value);
      _errorText = widget.validator?.call(value);
    });
    widget.onSelected?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    // autovalidateMode 为 always 时，每次重建都重新校验
    final errorText = widget.autoValidateMode == AutovalidateMode.always
        ? widget.validator?.call(_value)
        : _errorText;
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: _openPicker,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelText: widget.label,
        errorText: errorText,
        suffixIcon: widget.showClearButton && _value != null
            ? IconButton(
                tooltip: '清除',
                icon: const Icon(Icons.clear),
                onPressed: () => _updateValue(null),
              )
            : null,
      ),
    );
  }
}

/// [MyDropdownSearch] 的候选项弹窗：顶部搜索框 + 下方结果列表。
class _DropdownSearchDialog<T> extends StatefulWidget {
  final DropdownItemsLoader<T> loader;
  final T? selected;

  const _DropdownSearchDialog({required this.loader, this.selected});

  @override
  State<_DropdownSearchDialog<T>> createState() =>
      _DropdownSearchDialogState<T>();
}

class _DropdownSearchDialogState<T> extends State<_DropdownSearchDialog<T>> {
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  /// 自增的请求编号，用来丢弃先发后到的旧响应
  int _requestId = 0;

  List<T> _items = <T>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => _load(text));
  }

  Future<void> _load(String text) async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.loader(text);
      // 弹窗已关闭，或这条响应已经过期
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '搜索',
              contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            ),
            onChanged: _onSearchChanged,
          ),
          Flexible(child: _buildResult()),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_loading && _items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('加载失败：$error')),
      );
    }
    if (_items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('无结果')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _items[index];
        return ListTile(
          title: Text(item.toString()),
          selected: item == widget.selected,
          onTap: () => Navigator.of(context).pop(item),
        );
      },
    );
  }
}
