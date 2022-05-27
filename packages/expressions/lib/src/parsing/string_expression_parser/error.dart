part of 'parser.dart';

/// an error that can be thrown by the [StringExpressionParser],
/// if parsing has failed
class StringExpressionParseError implements Exception {
  /// the index of the character of the [String] at which the error begins
  final int from;

  /// the index of the first character after the error,
  /// if null only the from is important
  final int? to;

  /// the error message
  final String message;

  StringExpressionParseError(this.message, this.from, [this.to]);

  @override
  String toString() {
    return "At character $from to $to an error occurred: $message";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringExpressionParseError &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          message == other.message;

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ message.hashCode;
}
