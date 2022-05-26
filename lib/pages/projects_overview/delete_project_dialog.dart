import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/projects_overview/projects_overview_cubit.dart';

class DeleteProjectDialog extends StatefulWidget {
  final int deletionPendingProjectId;

  const DeleteProjectDialog({
    Key? key,
    required this.deletionPendingProjectId,
  }) : super(key: key);

  @override
  State<DeleteProjectDialog> createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
  void _deleteProject() {
    context
        .read<ProjectsOverviewCubit>()
        .deleteProject(widget.deletionPendingProjectId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final projectName = context
        .read<ProjectsOverviewCubit>()
        .state
        .projects!
        .where((project) => project.id == widget.deletionPendingProjectId);
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
          onPressed: _deleteProject,
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
