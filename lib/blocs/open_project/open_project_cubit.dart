import 'package:bloc/bloc.dart';
import 'package:flutter_plotter/repositories/projects/projects_repository_contract.dart';
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
    emit(state.copyWith(status: ProjectStatus.opening));
    final project = await projectsRepository.getProject(projectId);
    emit(OpenProjectState(status: ProjectStatus.saved, openProject: project));
  }

  void changeName(String newName) async {
    final openedProjectId = state.openProject!.id;
    final project =
        await projectsRepository.editProjectName(openedProjectId, newName);
    emit(state.copyWith(openProject: project));
  }

  void editPlotfile(String newPlotFile) {
    final oldProject = state.openProject!;
    emit(
      OpenProjectState(
        openProject: Project(
          id: oldProject.id,
          name: oldProject.name,
          plotFile: newPlotFile,
          createdAt: oldProject.createdAt,
        ),
        status: ProjectStatus.unsaved,
      ),
    );
  }

  void saveProject() async {
    emit(state.copyWith(status: ProjectStatus.saving));
    final editedProject = state.openProject!;
    await projectsRepository.editProjectPlotFile(
      editedProject.id,
      editedProject.plotFile,
    );
    emit(state.copyWith(status: ProjectStatus.saved));
  }

  void saveAndCloseProject() async {
    emit(state.copyWith(status: ProjectStatus.saving));
    final editedProject = state.openProject!;
    await projectsRepository.editProjectPlotFile(
      editedProject.id,
      editedProject.plotFile,
    );
    emit(const OpenProjectState());
  }

  void closeProject() {
    emit(const OpenProjectState());
  }

  void deleteProject() async {
    final openedProjectId = state.openProject!.id;
    emit(state.copyWith(status: ProjectStatus.deleting));
    await projectsRepository.deleteProject(openedProjectId);
    emit(const OpenProjectState());
  }
}
