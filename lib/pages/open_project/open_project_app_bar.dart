import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_edit_name_dialog.dart';
import 'package:f_plot/widgets/delete_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OpenProjectAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final openProjectCubit = context.read<OpenProjectCubit>();
    return BlocBuilder<OpenProjectCubit, OpenProjectState>(
      buildWhen: (_, newState) {
        return newState.projectIsOpen;
      },
      builder: (context, state) {
        final openProject = state.openProject!;
        return TextSelectionTheme(
          data: TextSelectionThemeData(
            selectionColor: Colors.white.withAlpha(100),
          ),
          child: Builder(builder: (context) {
            return AppBar(
              centerTitle: true,
              title: TextButton.icon(
                onPressed: () => showDialog(
                  useRootNavigator: false,
                  context: context,
                  builder: (_) => const OpenProjectEditNameDialog(),
                ),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(openProject.name),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  textStyle: MaterialStateProperty.all(
                    Theme.of(context).textTheme.headline6,
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
                        projectName: openProject.name,
                        onDelete: openProjectCubit.deleteProject,
                      ),
                    );
                  },
                )
              ],
            );
          }),
        );
      },
    );
  }
}
