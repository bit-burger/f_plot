import '../../domain/project.dart';
import '../../domain/project_listing.dart';

abstract class IProjectsRepository {
  Stream<List<ProjectListing>> get listingStream;

  void startListeningToProjects();
  Future<void> loadProjects();
  Future<ProjectListing> newProject(String name);
  Future<Project> getProject(int projectId);
  Future<void> editProjectName(int projectId, String newName);
  Future<void> editProjectPlotFile(int projectId, String newPlotFile);
  Future<void> deleteProject(int projectId);
  void dispose();
}
