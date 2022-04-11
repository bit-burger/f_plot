class ParseError implements Exception {
  final int from;
  final int? to;
  final String message;

  ParseError(this.message, this.from, [this.to]);

  @override
  String toString() {
    return "At character $from an error occurred: $message";
  }
}
