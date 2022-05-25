import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/projects_overview/projects_overview_cubit.dart';
import '../domain/project_listing.dart';

class ProjectsViewPage extends StatelessWidget {
  static const dateFormat = "dd.mm.yyyy HH:mm";
  static final dateFormatter = DateFormat(dateFormat);

  const ProjectsViewPage({super.key});

  void _showNewProjectDialog(
    BuildContext context,
    ProjectsOverviewCubit projectsOverviewCubit,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: projectsOverviewCubit,
          child: const AddNewProjectDialog(),
        );
      },
    );
  }

  Widget _projectsList(List<ProjectListing> projects) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, projectIndex) {
        final project = projects[projectIndex];
        return ListTile(
          title: Text(project.name),
          subtitle: Text(dateFormatter.format(project.createdAt)),
          onTap: () {
            context.read<OpenProjectCubit>().openProject(project.id);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<ProjectsOverviewCubit>().deleteProject(project.id);
            },
          ),
        );
      },
    );
  }

  Widget _emptyProjects(BuildContext context) {
    return Center(
      child: Text(
        "no projects",
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsOverviewCubit = context.watch<ProjectsOverviewCubit>();
    final projectsOverviewState = projectsOverviewCubit.state;
    final projects = projectsOverviewState.projects!;
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text("F Plot"),
        actions: [
          IconButton(
            onPressed: () => _showNewProjectDialog(
              context,
              projectsOverviewCubit,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:
          projects.isEmpty ? _emptyProjects(context) : _projectsList(projects),
    );
  }
}

class AddNewProjectDialog extends StatefulWidget {
  const AddNewProjectDialog({Key? key}) : super(key: key);

  @override
  State<AddNewProjectDialog> createState() => _AddNewProjectDialogState();
}

class _AddNewProjectDialogState extends State<AddNewProjectDialog> {
  late final TextEditingController _nameTextController;

  void _addNewProject() {
    final name = _nameTextController.text;
    if (name.isEmpty) return;
    context.read<ProjectsOverviewCubit>().newProject(name);
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
