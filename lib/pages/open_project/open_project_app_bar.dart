import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_edit_name_dialog.dart';
import 'package:f_plot/widgets/delete_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OpenProjectAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildTitle(BuildContext context) {
    return Tooltip(
      message: "edit project name",
      child: TextButton.icon(
        onPressed: () => showDialog(
          useRootNavigator: false,
          context: context,
          builder: (_) => const OpenProjectEditNameDialog(),
        ),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: BlocBuilder<OpenProjectCubit, OpenProjectState>(
          buildWhen: (oldState, newState) =>
              newState.projectIsOpen &&
              oldState.openProject?.name != newState.openProject!.name,
          builder: (context, state) {
            return Text(state.openProject!.name);
          },
        ),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocBuilder<OpenProjectCubit, OpenProjectState>(
      buildWhen: (oldState, newState) =>
          oldState.status != newState.status && !newState.openingOrDeleting && newState.projectIsOpen,
      builder: (context, state) {
        late final Widget widget;
        switch (state.status) {
          case ProjectStatus.saved:
            widget = const IconButton(
              key: ValueKey("saved"),
              tooltip: "saved",
              onPressed: null,
              icon: Icon(Icons.save_outlined),
            );
            break;
          case ProjectStatus.unsaved:
            widget = IconButton(
              key: const ValueKey("unsaved"),
              tooltip: "save",
              onPressed: context.read<OpenProjectCubit>().saveProject,
              icon: const Icon(Icons.save),
            );
            break;
          case ProjectStatus.saving:
            widget = const CircularProgressIndicator.adaptive();
            break;
          default:
            throw StateError("should not be able to reach this point");
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget,
        );
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      tooltip: "delete project",
      icon: const Icon(Icons.delete),
      onPressed: () {
        final cubit = context.read<OpenProjectCubit>();
        showDialog(
          context: context,
          builder: (_) => DeleteProjectDialog(
            projectName: cubit.state.openProject!.name,
            onDelete: cubit.deleteProject,
          ),
        );
      },
    );
  }

  Future<bool> _shouldExitPage(BuildContext context) async {
    final cubit = context.read<OpenProjectCubit>();
    if (cubit.state.status ==
        ProjectStatus.unsaved) {
      final shouldDiscardResult = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("do you want to discard unsaved changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("save and exit"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("discard"),
            ),
          ],
        ),
      );
      switch(shouldDiscardResult) {
        case true:
          return true;
        case false:
          cubit.saveAndCloseProject();
          return false;
        case null:
          return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _shouldExitPage(context),
      child: AppBar(
        title: _buildTitle(context),
        actions: [
          _buildSaveButton(context),
          _buildDeleteButton(context),
        ],
      ),
    );
  }
}
