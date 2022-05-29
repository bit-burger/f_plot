part of 'selected_error_cubit.dart';

class SelectedErrorState extends Equatable {
  final String? selectedErrorMessage;

  bool get errorIsSelected => selectedErrorMessage != null;

  const SelectedErrorState({this.selectedErrorMessage});

  @override
  List<Object?> get props => [errorIsSelected];
}
