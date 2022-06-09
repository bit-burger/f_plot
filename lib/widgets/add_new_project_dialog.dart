import 'package:flutter/material.dart';

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String textFieldHint;
  final ValueChanged<String> onTextFieldSubmit;

  const TextFieldDialog({
    super.key,
    required this.onTextFieldSubmit,
    required this.title,
    required this.textFieldHint,
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  late final TextEditingController _nameTextController;

  void _addNewProject() {
    final name = _nameTextController.text;
    if (name.isEmpty) return;
    widget.onTextFieldSubmit(name);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        focusNode: FocusNode()..requestFocus(),
        controller: _nameTextController,
        onSubmitted: (_) => _addNewProject(),
        decoration: InputDecoration(
          hintText: widget.textFieldHint,
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("cancel"),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _nameTextController,
          builder: (context, value, widget) {
            final disabled = value.text.isEmpty;
            return OutlinedButton(
              onPressed: disabled ? null : _addNewProject,
              child: const Text("submit"),
            );
          },
        ),
      ],
    );
  }
}
