import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'selected_error_state.dart';

class SelectedErrorCubit extends Cubit<SelectedErrorState> {
  SelectedErrorCubit() : super(const SelectedErrorState());

  void noErrorSelected() {
    emit(const SelectedErrorState());
  }

  void select(String? errorMessage) {
    emit(SelectedErrorState(selectedErrorMessage: errorMessage));
  }
}
