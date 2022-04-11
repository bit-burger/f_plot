import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'open_project_state.dart';

class OpenProjectCubit extends Cubit<OpenProjectState> {
  OpenProjectCubit() : super(InitialOpenProjectState());

  void openProject(int projectId) {
    emit(ProjectOpened(projectId));
  }

  void closeProject() {
    emit(NoProjectOpened());
  }
}
