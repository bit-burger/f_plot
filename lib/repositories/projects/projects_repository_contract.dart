import 'package:f_plot/domain/project.dart';

abstract class IProjectsRepository {
  Future<Project> newProject(String name);
  Future<List<Project>> getProjects();
  Future<void> deleteProject(int projectId);
}
