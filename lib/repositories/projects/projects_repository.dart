import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/domain/project.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';

class ProjectsRepository implements IProjectsRepository {
  final ProjectsDao dao;

  ProjectsRepository(this.dao);

  @override
  Future<Project> newProject(String name) {
    return dao.newProject(name);
  }

  @override
  Future<List<Project>> getProjects() {
    return dao.getProjects();
  }

  @override
  Future<void> deleteProject(int projectId) {
    return dao.deleteProject(projectId);
  }
}
