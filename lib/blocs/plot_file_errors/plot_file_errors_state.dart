part of 'plot_file_errors_cubit.dart';

class PlotFileErrorsState extends Equatable {
  final List<PlotFileError> errors;
  final PlotFileError? selectedError;
  final int? lastSelectedErrorCursorPosition;

  bool get errorIsSelected => selectedError != null;
  int get selectedErrorIndex => errors.indexWhere(
        (error) => error == selectedError,
      );

  const PlotFileErrorsState({
    this.errors = const [],
    this.selectedError,
    this.lastSelectedErrorCursorPosition,
  });

  const factory PlotFileErrorsState.initial() = PlotFileErrorsState;

  @override
  List<Object?> get props =>
      [errors, selectedError, lastSelectedErrorCursorPosition];

  PlotFileErrorsState copyWith({
    List<PlotFileError>? errors,
    PlotFileError? selectedError,
    int? lastSelectedErrorCursorPosition,
  }) {
    return PlotFileErrorsState(
      errors: errors ?? this.errors,
      selectedError: selectedError ?? this.selectedError,
      lastSelectedErrorCursorPosition: lastSelectedErrorCursorPosition ??
          this.lastSelectedErrorCursorPosition,
    );
  }
}
