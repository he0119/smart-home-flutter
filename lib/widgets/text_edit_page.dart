import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/widgets/home_page.dart';

class TextEditPage extends StatefulWidget {
  final String title;
  final String initialValue;
  final String description;
  final ValueChanged<String> onSubmit;
  final String? Function(String value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const TextEditPage({
    super.key,
    required this.title,
    required this.initialValue,
    required this.description,
    required this.onSubmit,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  State<TextEditPage> createState() => _TextEditPageState();
}

class _TextEditPageState extends State<TextEditPage> {
  late TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _textController = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          tooltip: '保存',
          icon: const Icon(Icons.check),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_textController.text);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _textController,
                  autofocus: true,
                  validator: (value) {
                    if (widget.validator != null) {
                      return widget.validator!(value ?? '');
                    }
                    return null;
                  },
                  autovalidateMode: .onUserInteraction,
                  inputFormatters: widget.inputFormatters,
                  keyboardType: widget.keyboardType,
                  decoration: const InputDecoration(errorMaxLines: 2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
