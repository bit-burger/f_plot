import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/blocs/projects_overview/projects_overview_cubit.dart';
import 'package:f_plot/pages/projects_navigator/loading_overlay_page.dart';
import 'package:f_plot/pages/open_project/open_project_page.dart';
import 'package:f_plot/pages/projects_navigator/splash_loading_screen.dart';
import 'package:f_plot/pages/projects_overview/projects_overview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsNavigator extends StatelessWidget {
  const ProjectsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsOverviewCubit = context.watch<ProjectsOverviewCubit>();
    final projectsOverviewState = projectsOverviewCubit.state;
    final openProjectCubit = context.watch<OpenProjectCubit>();
    final openProjectState = openProjectCubit.state;

    return Navigator(
      pages: [
        MaterialPage(
          key: const ValueKey("splash"),
          name: "splash loading screen",
          child: WillPopScope(
            onWillPop: () async => false,
            child: const SplashLoadingScreen(),
          ),
        ),
        if (projectsOverviewState.projectsHaveLoaded)
          MaterialPage(
            key: const ValueKey("projects_overview"),
            name: "all projects",
            child: WillPopScope(
              onWillPop: () async => false,
              child: const ProjectsOverviewPage(),
            ),
          ),
        if (openProjectState.projectIsOpen)
          MaterialPage(
            key: const ValueKey("projects_is_open"),
            name: "project: ${openProjectState.openProject!.name}",
            child: const OpenProjectPage(),
          ),
        if ((projectsOverviewState.isLoading &&
                projectsOverviewState.projectsHaveLoaded) ||
            openProjectState.isLoading)
          const LoadingOverlayPage(
            key: ValueKey("loading"),
            name: "loading...",
          ),
      ],
      onPopPage: (route, result) {
        openProjectCubit.closeProject();
        return route.didPop(result);
      },
    );
  }
}

