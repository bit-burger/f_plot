part of 'plot_file_errors_cubit.dart';

class PlotFileError extends CodeError {
  final int lineBegin;
  final int lineBeginFirstCharacter;

  PlotFileError._({
    required this.lineBegin,
    required this.lineBeginFirstCharacter,
    required super.begin,
    required super.end,
    required super.message,
  });

  factory PlotFileError.fromGlobalCharacter({
    required int globalCharacterBegin,
    required int globalCharacterEnd,
    required String plotFile,
    required String message,
  }) {
    var line = 0;
    var lineCharacter = 0;
    var lineBreak = false;
    for (var i = 0; i < globalCharacterBegin; i++) {
      if (lineBreak) {
        lineCharacter = 0;
        lineBreak = false;
      } else {
        lineCharacter++;
      }
      if (plotFile[i] == "\n") {
        line++;
        lineBreak = true;
      }
    }
    return PlotFileError._(
      lineBegin: line,
      lineBeginFirstCharacter: lineCharacter,
      begin: globalCharacterBegin,
      end: globalCharacterEnd,
      message: message,
    );
  }

  factory PlotFileError.fromStringExpressionParseError({
    required StringExpressionParseError error,
    required String plotFile,
  }) {
    return PlotFileError.fromGlobalCharacter(
      globalCharacterBegin: error.from,
      globalCharacterEnd: error.to ?? (error.from + 1),
      plotFile: plotFile,
      message: error.message,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlotFileError &&
          begin == other.begin &&
          end == other.end &&
          lineBegin == other.lineBegin &&
          lineBeginFirstCharacter == other.lineBeginFirstCharacter &&
          message == other.message);
}
