import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/widgets/storage_picker_sheet.dart';

class StorageFormField extends ConsumerStatefulWidget {
  const StorageFormField({
    // From super
    super.key,
    this.validator,
    this.initialValue,
    this.autovalidateMode,
    this.enabled = true,
    this.decoration = const InputDecoration(),
    this.onChanged,
  });

  final FormFieldValidator<Storage>? validator;
  final Storage? initialValue;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final InputDecoration? decoration;
  final void Function(Storage? value)? onChanged;

  @override
  ConsumerState<StorageFormField> createState() => _StorageFieldState();
}

class _StorageFieldState extends ConsumerState<StorageFormField> {
  bool isShowingDialog = false;
  bool hadFocus = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Storage? _value;
  String? _errorText;

  bool get hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue?.name);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration effectiveDecoration =
        (widget.decoration ?? const InputDecoration()).applyDefaults(
          Theme.of(context).inputDecorationTheme,
        );
    return TextField(
      focusNode: _focusNode,
      controller: _controller,
      decoration: effectiveDecoration.copyWith(
        errorText: _errorText,
        suffixIcon: shouldShowClearIcon(effectiveDecoration)
            ? IconButton(
                tooltip: '清除',
                icon: const Icon(Icons.close),
                onPressed: clear,
              )
            : null,
      ),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void reset() {
    _controller.text = widget.initialValue?.name ?? '';
    _updateValue(widget.initialValue);
  }

  void _updateValue(Storage? value) {
    setState(() {
      _value = value;
      _errorText = widget.validator?.call(value);
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  void _handleFocusChanged() {
    if (hasFocus && !hadFocus) {
      hadFocus = hasFocus;
      _hideKeyboard();
      requestUpdate();
    } else {
      hadFocus = hasFocus;
    }
  }

  void _hideKeyboard() {
    // ignore: use_build_context_synchronously
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  Future<void> requestUpdate() async {
    if (isShowingDialog) {
      return;
    }
    isShowingDialog = true;
    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final storages = await storageRepository.storages(key: '', cache: false);
      if (!mounted) {
        return;
      }
      final result = await showStoragePicker(
        context,
        current: _value,
        storages: storages,
      );
      // 直接关掉弹窗时 result 为 null，保持原值
      if (!mounted || result == null) {
        return;
      }
      if (result.cleared) {
        _controller.clear();
        _updateValue(null);
        return;
      }
      final storage = result.storage!;
      // 又选了同一个位置就不必再触发一次 onChanged
      if (_value?.id == storage.id) {
        _controller.text = storage.name;
        return;
      }
      _controller.text = storage.name;
      _updateValue(storage);
    } finally {
      isShowingDialog = false;
    }
  }

  void clear() async {
    _hideKeyboard();
    setState(() {
      _controller.clear();
      _updateValue(null);
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      (_controller.text != '' || hasFocus) && decoration?.suffixIcon == null;
}
