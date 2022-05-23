import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';
import 'package:meta/meta.dart';

import '../../domain/project_listing.dart';

part 'projects_overview_state.dart';

class ProjectsOverviewCubit extends Cubit<ProjectsOverviewState> {
  final IProjectsRepository projectsRepository;
  late final StreamSubscription<List<ProjectListing>> _sub;

  ProjectsOverviewCubit(this.projectsRepository) : super(ProjectsOverviewState.initial());

  void loadProjects() {
    projectsRepository.startListeningToProjects();
    emit(const ProjectsOverviewState(isLoading: true));
    _sub = projectsRepository.listingStream.listen(listingUpdate);
  }

  void listingUpdate(List<ProjectListing> newProjectListing) {
    emit(ProjectsOverviewState(projects: newProjectListing));
  }

  void deleteProject(int projectId) {
    emit(state.copyWith(isLoading: true));
    projectsRepository.deleteProject(projectId);
  }

  void newProject(String name) {
    emit(state.copyWith(isLoading: true));
    projectsRepository.newProject(name);
  }
}
