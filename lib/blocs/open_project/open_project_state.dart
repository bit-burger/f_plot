part of 'open_project_cubit.dart';

@immutable
abstract class OpenProjectState {}

class InitialOpenProjectState extends OpenProjectState {}

class NoProjectOpened extends OpenProjectState {}

class ProjectOpened extends OpenProjectState {
  final int projectId;

  ProjectOpened(this.projectId);
}
