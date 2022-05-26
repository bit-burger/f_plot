import 'package:flutter/material.dart';

class AddNewProjectDialog extends StatefulWidget {
  final ValueChanged<String> onNewProjectSuccess;
  const AddNewProjectDialog({super.key, required this.onNewProjectSuccess});

  @override
  State<AddNewProjectDialog> createState() => _AddNewProjectDialogState();
}

class _AddNewProjectDialogState extends State<AddNewProjectDialog> {
  late final TextEditingController _nameTextController;

  void _addNewProject() {
    final name = _nameTextController.text;
    if (name.isEmpty) return;
    widget.onNewProjectSuccess(name);
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
      title: const Text("Add a new project"),
      content: TextField(
        focusNode: FocusNode()..requestFocus(),
        controller: _nameTextController,
        onSubmitted: (_) => _addNewProject(),
        decoration: const InputDecoration(
          hintText: "project name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("cancel"),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _nameTextController,
          builder: (context, value, widget) {
            final disabled = value.text.isEmpty;
            return TextButton(
              onPressed: disabled ? null : _addNewProject,
              child: const Text("submit"),
            );
          },
        ),
      ],
    );
  }
}
