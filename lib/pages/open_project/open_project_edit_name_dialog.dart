import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectEditNameDialog extends StatefulWidget {
  const OpenProjectEditNameDialog({super.key});

  @override
  State<OpenProjectEditNameDialog> createState() =>
      _OpenProjectEditNameDialogState();
}

class _OpenProjectEditNameDialogState extends State<OpenProjectEditNameDialog> {
  late final TextEditingController _nameTextEditingController;

  void _changeName() {
    context
        .read<OpenProjectCubit>()
        .changeName(_nameTextEditingController.text);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final openProject = context.read<OpenProjectCubit>().state.openProject!;
    _nameTextEditingController = TextEditingController(text: openProject.name);
  }

  @override
  Widget build(BuildContext context) {
    final openProjectCubit = context.read<OpenProjectCubit>().state;
    final currentName = openProjectCubit.openProject!.name;
    return AlertDialog(
      title: Text("Change the name of the project $currentName"),
      content: TextField(
        autofocus: true,
        controller: _nameTextEditingController,
        onSubmitted: (_) => _changeName(),
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
        TextButton(
          onPressed: _changeName,
          child: const Text("change name"),
        ),
      ],
    );
  }
}
