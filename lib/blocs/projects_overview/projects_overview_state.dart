part of 'projects_overview_cubit.dart';

@immutable
class ProjectsOverviewState {
  final bool isLoading;
  final List<ProjectListing> projects;

  const ProjectsOverviewState({
    this.isLoading = false,
    this.projects = const [],
  });

  factory ProjectsOverviewState.initial() {
    return const ProjectsOverviewState();
  }

  ProjectsOverviewState copyWith({
    bool? isLoading,
    List<ProjectListing>? projects,
  }) {
    return ProjectsOverviewState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
    );
  }
}
