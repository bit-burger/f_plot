import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/projects_overview/projects_overview_cubit.dart';
import '../../domain/project_listing.dart';
import 'add_new_project_dialog.dart';
import 'delete_project_dialog.dart';

class ProjectsOverviewPage extends StatelessWidget {
  static const dateFormat = "dd.mm.yyyy HH:mm";
  static final dateFormatter = DateFormat(dateFormat);

  const ProjectsOverviewPage({super.key});

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

  void _showDeleteProjectDialog(
    BuildContext context,
    ProjectsOverviewCubit projectsOverviewCubit,
    int deletionPendingProjectId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: projectsOverviewCubit,
          child: DeleteProjectDialog(
            deletionPendingProjectId: deletionPendingProjectId,
          ),
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
              _showDeleteProjectDialog(
                context,
                context.read<ProjectsOverviewCubit>(),
                project.id,
              );
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
