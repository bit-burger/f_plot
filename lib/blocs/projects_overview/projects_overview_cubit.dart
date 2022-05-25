import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';
import 'package:meta/meta.dart';

import '../../domain/project_listing.dart';

part 'projects_overview_state.dart';

class ProjectsOverviewCubit extends Cubit<ProjectsOverviewState> {
  final IProjectsRepository projectsRepository;
  late final StreamSubscription<List<ProjectListing>> _sub;

  ProjectsOverviewCubit({
    required this.projectsRepository,
  }) : super(ProjectsOverviewState.initial());

  void loadProjects() {
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

  void newProject(String name) async {
    emit(state.copyWith(isLoading: true));
    await projectsRepository.newProject(name);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
