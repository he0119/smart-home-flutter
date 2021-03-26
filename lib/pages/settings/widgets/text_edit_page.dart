import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEditPage extends StatefulWidget {
  final String title;
  final String initialValue;
  final String description;
  final ValueChanged<String> onSubmit;
  final String? Function(String value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const TextEditPage({
    Key? key,
    required this.title,
    required this.initialValue,
    required this.description,
    required this.onSubmit,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  @override
  _TextEditPageState createState() => _TextEditPageState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Tooltip(
            message: '确认',
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(_textController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: widget.inputFormatters,
                keyboardType: widget.keyboardType,
              ),
            ),
            SizedBox(height: 12),
            Text(widget.description),
          ],
        ),
      ),
    );
  }
}
