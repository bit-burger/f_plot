part of 'projects_cubit.dart';

@immutable
abstract class ProjectsState {}

class InitialProjectsState extends ProjectsState {}

class ProjectsLoadingState extends ProjectsState {}

class ProjectsLoadingErrorState extends ProjectsState {
  final String message;

  ProjectsLoadingErrorState(this.message);
}

class ProjectsDataState extends ProjectsState {
  final List<Project> projects;

  ProjectsDataState(this.projects);
}
