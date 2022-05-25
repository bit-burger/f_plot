import 'dart:async';

import 'package:f_plot/database/projects_dao.dart';
import 'package:f_plot/domain/project.dart';
import 'package:f_plot/domain/project_listing.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';

// class ProjectsRepository implements IProjectsRepository {
//   final ProjectsDao projectsDao;
//
//   late List<ProjectListing> _lastListing;
//   late final StreamController<List<ProjectListing>> _controller;
//
//   @override
//   Stream<List<ProjectListing>> get listingStream => _controller.stream;
//
//   ProjectsRepository({required this.projectsDao});
//
//   @override
//   void startListeningToProjects() {
//     _controller = StreamController.broadcast();
//     loadProjects();
//   }
//
//   void _addToStream(List<ProjectListing> listing) {
//     _controller.add(listing);
//     _lastListing = listing;
//   }
//
//   @override
//   Future<void> loadProjects() async {
//     final projects = await projectsDao.getProjects();
//     _addToStream(projects);
//   }
//
//   @override
//   Future<ProjectListing> newProject(String name) async {
//     final project = await projectsDao.newProject(name);
//     _addToStream(
//       [..._lastListing, project]..sort((a, b) => a.name.compareTo(b.name)),
//     );
//     return project;
//   }
//
//   @override
//   Future<Project> getProject(int projectId) async {
//     final project = await projectsDao.getProject(projectId);
//     return project;
//   }
//
//   @override
//   Future<void> editProjectName(int projectId, String newName) async {
//     await projectsDao.editProjectName(projectId, newName);
//     final projects = [..._lastListing];
//     final editedProjectIndex =
//         projects.indexWhere((project) => project.id == projectId);
//     projects[editedProjectIndex] = ProjectListing(
//       id: projectId,
//       name: newName,
//       createdAt: projects[editedProjectIndex].createdAt,
//     );
//     _addToStream(projects);
//   }
//
//   @override
//   Future<void> editProjectPlotFile(int projectId, String newPlotFile) async {
//     await projectsDao.editProjectPlotFile(projectId, newPlotFile);
//   }
//
//   @override
//   Future<void> deleteProject(int projectId) async {
//     await projectsDao.deleteProject(projectId);
//     _addToStream(
//       [..._lastListing]..removeWhere((project) => project.id == projectId),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.close();
//   }
// }

// import 'dart:async';
//
// import 'package:f_plot/database/projects_dao.dart';
// import 'package:f_plot/domain/project.dart';
// import 'package:f_plot/domain/project_listing.dart';
// import 'package:f_plot/repositories/projects/projects_repository_contract.dart';
//
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
    loadProjects();
    return project;
  }

  @override
  Future<Project> getProject(int projectId) async {
    final project = await projectsDao.getProject(projectId);
    return project;
  }

  @override
  Future<void> editProjectName(int projectId, String newName) async {
    await projectsDao.editProjectName(projectId, newName);
    loadProjects();
  }

  @override
  Future<void> editProjectPlotFile(int projectId, String newPlotFile) async {
    await projectsDao.editProjectPlotFile(projectId, newPlotFile);
    loadProjects();
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await projectsDao.deleteProject(projectId);
    loadProjects();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
