import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

class DateTimePickerFormField extends StatefulWidget {
  final InputDecoration decoration;
  final DateFormat format;
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;

  const DateTimePickerFormField({
    super.key,
    required this.decoration,
    required this.format,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<DateTimePickerFormField> createState() =>
      _DateTimePickerFormFieldState();
}

class _DateTimePickerFormFieldState extends State<DateTimePickerFormField> {
  late final TextEditingController _controller;
  DateTime? _value;

  @override
  void didUpdateWidget(covariant DateTimePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _value = widget.initialValue;
      _syncText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController();
    _syncText();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: widget.decoration.copyWith(
        suffixIcon: _value == null
            ? const Icon(Icons.event)
            : IconButton(
                tooltip: '清除',
                icon: const Icon(Icons.clear),
                onPressed: () => _updateValue(null),
              ),
      ),
      readOnly: true,
      onTap: _pickDateTime,
    );
  }

  Future<void> _pickDateTime() async {
    final currentValue = _value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: currentValue,
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
    );
    if (!mounted) {
      return;
    }

    _updateValue(
      DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      ),
    );
  }

  void _syncText() {
    _controller.text = _value == null
        ? ''
        : widget.format.format(_value!.toLocal());
  }

  void _updateValue(DateTime? value) {
    setState(() {
      _value = value;
      _syncText();
    });
    widget.onChanged(value);
  }
}

Widget _dateTimePickerPreviewFrame(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

@Preview(name: 'DateTimePickerFormField empty')
Widget dateTimePickerFormFieldEmptyPreview() {
  return _dateTimePickerPreviewFrame(
    DateTimePickerFormField(
      decoration: const InputDecoration(labelText: '有效期至'),
      format: DateFormat.yMMMd().add_Hms(),
      onChanged: (_) {},
    ),
  );
}

@Preview(name: 'DateTimePickerFormField selected')
Widget dateTimePickerFormFieldSelectedPreview() {
  return _dateTimePickerPreviewFrame(
    DateTimePickerFormField(
      decoration: const InputDecoration(labelText: '有效期至'),
      format: DateFormat.yMMMd().add_Hms(),
      initialValue: DateTime(2026, 5, 21, 12, 30),
      onChanged: (_) {},
    ),
  );
}
