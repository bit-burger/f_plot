part of 'projects_overview_cubit.dart';

@immutable
class ProjectsOverviewState {
  final bool isLoading;
  final List<ProjectListing>? projects;

  bool get projectsHaveLoaded => projects != null;

  const ProjectsOverviewState({
    this.isLoading = false,
    this.projects,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectsOverviewState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          projects == other.projects;

  @override
  int get hashCode => isLoading.hashCode ^ projects.hashCode;

  @override
  String toString() {
    return 'ProjectsOverviewState{isLoading: $isLoading, projects: $projects}';
  }
}
