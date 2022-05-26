import 'package:bloc/bloc.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';
import 'package:meta/meta.dart';

import '../../domain/project.dart';

part 'open_project_state.dart';

class OpenProjectCubit extends Cubit<OpenProjectState> {
  final IProjectsRepository projectsRepository;

  OpenProjectCubit({
    required this.projectsRepository,
  }) : super(OpenProjectState.initial());

  void noProjectOpened() {
    emit(const OpenProjectState());
  }

  void openProject(int projectId) async {
    emit(state.copyWith(isLoading: true));
    final project = await projectsRepository.getProject(projectId);
    emit(OpenProjectState(isLoading: false, openProject: project));
  }

  void editName(String newName) async {
    final openedProjectId = state.openProject!.id;
    final project = await projectsRepository.editProjectName(openedProjectId, newName);
    emit(state.copyWith(openProject: project));
  }

  void closeProject() {
    emit(const OpenProjectState());
  }

  void deleteProject() async {
    final openedProjectId = state.openProject!.id;
    emit(state.copyWith(isLoading: true));
    await projectsRepository.deleteProject(openedProjectId);
    emit(const OpenProjectState());
  }
}
