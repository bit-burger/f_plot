import 'package:flutter/material.dart';

class DeleteProjectDialog extends StatelessWidget {
  final String projectName;
  final VoidCallback onDelete;

  const DeleteProjectDialog({
    super.key,
    required this.onDelete,
    required this.projectName,
  });

  void _deleteProject(BuildContext context) {
    onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete a project"),
      content: Text(
          "are you sure that you want to delete the project $projectName?"),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("cancel"),
        ),
        OutlinedButton(
          onPressed: () => _deleteProject(context),
          child: const Text("delete"),
        ),
      ],
    );
  }
}
