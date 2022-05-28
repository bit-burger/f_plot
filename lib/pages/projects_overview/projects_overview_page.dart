import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/projects_overview/projects_overview_cubit.dart';
import '../../domain/project_listing.dart';
import '../../widgets/add_new_project_dialog.dart';
import '../../widgets/delete_project_dialog.dart';

class ProjectsOverviewPage extends StatelessWidget {
  static const dateFormat = "dd.mm.yyyy HH:mm";
  static final dateFormatter = DateFormat(dateFormat);

  const ProjectsOverviewPage({super.key});

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
            tooltip: "delete project ${project.name}",
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => DeleteProjectDialog(
                  projectName: project.name,
                  onDelete: () => context
                      .read<ProjectsOverviewCubit>()
                      .deleteProject(project.id),
                ),
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
            icon: const Icon(Icons.add),
            tooltip: "add new project",
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddNewProjectDialog(
                  onNewProjectSuccess: projectsOverviewCubit.newProject,
                ),
              );
            },
          ),
        ],
      ),
      body:
          projects.isEmpty ? _emptyProjects(context) : _projectsList(projects),
    );
  }
}
