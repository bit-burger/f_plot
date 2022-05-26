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
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("cancel"),
        ),
        TextButton(
          onPressed: () => _deleteProject(context),
          child: Text(
            "delete",
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).errorColor.withAlpha(50);
                }
                return null;
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) {
                if (states.contains(MaterialState.hovered)) {
                  return Theme.of(context).errorColor.withAlpha(24);
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
