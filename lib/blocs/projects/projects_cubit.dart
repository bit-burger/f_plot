import 'package:bloc/bloc.dart';
import 'package:f_plot/domain/project.dart';
import 'package:meta/meta.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit() : super(InitialProjectsState());
}
