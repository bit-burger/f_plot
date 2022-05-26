import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/widgets/delete_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectAppBar extends StatefulWidget implements PreferredSizeWidget {
  const OpenProjectAppBar({Key? key}) : super(key: key);

  @override
  State<OpenProjectAppBar> createState() => _OpenProjectAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _OpenProjectAppBarState extends State<OpenProjectAppBar> {
  late final TextEditingController _projectNameTextController;

  @override
  void initState() {
    super.initState();

    final openProjectState = context.read<OpenProjectCubit>().state;
    _projectNameTextController =
        TextEditingController(text: openProjectState.openProject!.name);
  }

  @override
  Widget build(BuildContext context) {
    final openProjectCubit = context.read<OpenProjectCubit>();
    final openProject = openProjectCubit.state.openProject;
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: Colors.white.withAlpha(100),
      ),
      child: Builder(builder: (context) {
        return AppBar(
          centerTitle: true,
          title: IntrinsicWidth(
            child: TextField(
              textAlign: TextAlign.center,
              controller: _projectNameTextController,
              onSubmitted: (projectName) {
                openProjectCubit.editName(projectName);
              },
              style: const TextStyle(fontSize: 20, color: Colors.white),
              cursorColor: Colors.white,
              selectionControls: MaterialTextSelectionControls(),
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.edit, color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => DeleteProjectDialog(
                    projectName: openProject!.name,
                    onDelete: openProjectCubit.deleteProject,
                  ),
                );
              },
            )
          ],
        );
      }),
    );
  }
}
