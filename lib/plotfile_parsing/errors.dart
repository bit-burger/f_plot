class ParseError {
  final int line;
  final int? char;
  final String message;

  ParseError(this.line, this.char, this.message);

  @override
  String toString() {
    return "On line $line, on char $char, an error was found: $message";
  }
}
