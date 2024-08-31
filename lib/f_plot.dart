import 'package:flutter_plotter/blocs/open_project/open_project_cubit.dart';
import 'package:flutter_plotter/pages/projects_navigator/projects_navigator.dart';
import 'package:flutter_plotter/repositories/projects/projects_repository.dart';
import 'package:flutter_plotter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/projects_overview/projects_overview_cubit.dart';
import 'database/projects_dao.dart';

class FPlot extends StatelessWidget {
  final ProjectsDao projectsDao;

  const FPlot({super.key, required this.projectsDao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: fPlotTheme,
      debugShowCheckedModeBanner: false,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (_) => ProjectsRepository(projectsDao: projectsDao)
              ..startListeningToProjects(),
          ),
        ],
        child: Builder(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProjectsOverviewCubit>(
                create: (_) => ProjectsOverviewCubit(
                  projectsRepository: context.read<ProjectsRepository>(),
                )..loadProjects(),
              ),
              BlocProvider<OpenProjectCubit>(
                create: (_) => OpenProjectCubit(
                  projectsRepository: context.read<ProjectsRepository>(),
                )..noProjectOpened(),
              ),
            ],
            child: ProjectsNavigator(),
          );
        }),
      ),
    );
  }
}
