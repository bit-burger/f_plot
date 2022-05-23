import 'dart:async';

import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/domain/project.dart';
import 'package:f_plot/domain/project_listing.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';

class ProjectsRepository implements IProjectsRepository {
  final ProjectsDao dao;

  late final StreamController<List<ProjectListing>> _controller;

  @override
  Stream<List<ProjectListing>> get listingStream => _controller.stream;

  ProjectsRepository(this.dao);

  @override
  void startListeningToProjects() {
    _controller = StreamController.broadcast();
  }

  @override
  Future<void> loadProjects() async {
    final projects = await dao.getProjects();
    _controller.add(projects);
  }

  @override
  Future<ProjectListing> newProject(String name) {
    final project = dao.newProject(name);
    loadProjects();
    return project;
  }

  @override
  Future<Project> getProject(int projectId) async {
    final project = await dao.getProject(projectId);
    return project;
  }

  @override
  Future<void> editProjectName(int projectId, String newName) async {
    await dao.editProjectName(projectId, newName);
    loadProjects();
  }

  @override
  Future<void> editProjectPlotFile(int projectId, String newPlotFile) async {
    await dao.editProjectPlotFile(projectId, newPlotFile);
    loadProjects();
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await dao.deleteProject(projectId);
    loadProjects();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
