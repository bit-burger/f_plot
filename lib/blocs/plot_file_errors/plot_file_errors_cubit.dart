import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expressions/expressions.dart';
import 'package:math_code_field/math_code_field.dart';
import '../plotting_project/plotting_project_cubit.dart';

part 'plot_file_errors_state.dart';
part 'plot_file_error.dart';

/// handle the errors that are emitted from the [PlottingProjectCubit]
/// and the selection of one of the errors with the text field
///
/// the clicking on a error to jump to it on the text field,
/// as well as if the cursor is on the same line as an error,
/// it should be shown extra should be handled.
class PlotFileErrorsCubit extends Cubit<PlotFileErrorsState> {
  late int? _currentCursorPosition;
  String _currentPlotFile = "";

  PlotFileErrorsCubit() : super(const PlotFileErrorsState.initial());

  PlotFileError? _firstErrorInRange(
    int begin,
    int last,
    List<PlotFileError> errors,
  ) {
    for (final error in errors) {
      final errorIsBeforeRange = last < error.begin && last < error.begin;
      final errorIsAfterRange = begin >= error.end && begin >= error.end;
      if (!errorIsBeforeRange && !errorIsAfterRange) {
        return error;
      }
    }
    return null;
  }

  PlotFileError? _firstErrorThatLiesInCursorLine(
    int cursorPosition,
    List<PlotFileError> errors,
  ) {
    var firstCharacterCursorLine = 0;
    var lineBreak = false;
    for (var i = 0; i < _currentPlotFile.length; i++) {
      if (lineBreak) {
        lineBreak = false;
        firstCharacterCursorLine = i;
      }
      if (_currentPlotFile[i] == "\n") {
        lineBreak = true;
      }
      if (i == cursorPosition) {
        break;
      }
    }
    var lastCharacterCursorLine = firstCharacterCursorLine;
    while (lastCharacterCursorLine < _currentPlotFile.length - 1 &&
        _currentPlotFile[lastCharacterCursorLine] != "\n") {
      lastCharacterCursorLine++;
    }
    return _firstErrorInRange(
        firstCharacterCursorLine, lastCharacterCursorLine, errors);
  }

  PlotFileError? _firstErrorThatLiesInCursor(
    int cursorPosition,
    List<PlotFileError> errors,
  ) {
    for (final error in errors) {
      if (cursorPosition >= error.begin && cursorPosition < error.end) {
        return error;
      }
      // make sure a error cannot be marked if it is on the line above,
      // even if it goes to the new line
      if (cursorPosition != 0 &&
          cursorPosition == error.end &&
          _currentPlotFile[cursorPosition - 1] != "\n") {
        return error;
      }
    }
    return null;
  }

  PlotFileError? _errorInCursorLine(
    int cursorPosition,
    List<PlotFileError> errors,
  ) {
    return _firstErrorThatLiesInCursor(cursorPosition, errors) ??
        _firstErrorThatLiesInCursorLine(cursorPosition, errors);
  }

  void updatePlotFile(
      List<StringExpressionParseError> errors, String plotFile) {
    _currentPlotFile = plotFile;
    final newErrors = errors
        .map((error) => PlotFileError.fromStringExpressionParseError(
            error: error, plotFile: plotFile))
        .toList(growable: false)
      ..sort(
        (a, b) {
          final firstCriteria = a.begin.compareTo(b.begin);
          if (firstCriteria != 0) {
            return firstCriteria;
          }
          return a.end.compareTo(b.end);
        },
      );
    emit(
      PlotFileErrorsState(
        selectedError: _currentCursorPosition == null
            ? null
            : _errorInCursorLine(_currentCursorPosition!, newErrors),
        errors: newErrors,
      ),
    );
  }

  void unfocusPlotFileEditor() {
    _currentCursorPosition = null;
    emit(
      PlotFileErrorsState(
        errors: state.errors,
      ),
    );
  }

  void changeCursorPosition(int cursorPosition) {
    if (_currentCursorPosition != cursorPosition) {
      final newSelectedError = _errorInCursorLine(cursorPosition, state.errors);
      if (newSelectedError != state.selectedError) {
        emit(
          PlotFileErrorsState(
            errors: state.errors,
            selectedError: newSelectedError,
          ),
        );
      }
      _currentCursorPosition = cursorPosition;
    }
  }

  void clickOnError(PlotFileError error) {
    emit(state.copyWith(lastSelectedErrorCursorPosition: error.begin));
  }
}
