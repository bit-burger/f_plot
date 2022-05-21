import 'package:math_code_field/src/code_field.dart';

/// represents an error that should be marked by the [MathCodeField]
class CodeError {
  /// the first character of the error
  final int begin;

  /// the first character after the error
  ///
  /// if [end] is null, only the character at [begin] will be marked
  final int? end;

  /// the message that should be displayed, if hovering over an error.
  ///
  /// if [message] is null, nothing will happen on hovering over the editor
  final String? message;

  int get realEnd => end ?? begin + 1;

  const CodeError({
    required this.begin,
    this.end,
    this.message,
  });
}
