import 'dart:async';

import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/domain/project.dart';
import 'package:f_plot/domain/project_listing.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';

class ProjectsRepository implements IProjectsRepository {
  final ProjectsDao projectsDao;

  late final StreamController<List<ProjectListing>> _controller;

  @override
  Stream<List<ProjectListing>> get listingStream => _controller.stream;

  ProjectsRepository({required this.projectsDao});

  @override
  void startListeningToProjects() {
    _controller = StreamController.broadcast();
    loadProjects();
  }

  @override
  Future<void> loadProjects() async {
    final projects = await projectsDao.getProjects();
    _controller.add(projects);
  }

  @override
  Future<ProjectListing> newProject(String name) async {
    final project = await projectsDao.newProject(name);
    await loadProjects();
    return project;
  }

  @override
  Future<ProjectListing> cloneProject(int projectId, String name) async {
    final project = await projectsDao.cloneProject(projectId, name);
    await loadProjects();
    return project;
  }

  @override
  Future<Project> getProject(int projectId) async {
    final project = await projectsDao.getProject(projectId);
    return project;
  }

  @override
  Future<Project> editProjectName(int projectId, String newName) async {
    final project = await projectsDao.editProjectName(projectId, newName);
    await loadProjects();
    return project;
  }

  @override
  Future<Project> editProjectPlotFile(int projectId, String newPlotFile) async {
    final project =
        await projectsDao.editProjectPlotFile(projectId, newPlotFile);
    return project;
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await projectsDao.deleteProject(projectId);
    await loadProjects();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
