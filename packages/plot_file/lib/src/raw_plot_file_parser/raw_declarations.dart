part of "raw_plot_file_parser.dart";

class RawDeclaration {
  late final String identifier;
  late final int identifierStart;
  late final int identifierEnd;
  late final int bodyStart;
  late final int bodyEnd;
  late final String body;

  RawDeclaration(this.identifierStart, this.identifierEnd, this.identifier);

  @override
  // just for debugging purposes
  bool operator ==(Object other) =>
      other is RawDeclaration && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;

  void fillBody(String s) {
    body = s.substring(bodyStart, bodyEnd);
  }
}

class RawFunctionDeclaration extends RawDeclaration {
  late final int parametersStart;
  late final int parametersEnd;
  late final List<String> parameters;

  @override
  String toString() {
    return 'RawFunctionDeclaration{\n'
        'identifier: $identifier,\n'
        'identifierStart: $identifierStart,\n'
        'identifierEnd: $identifierEnd,\n'
        'parameters: $parameters,\n'
        'parametersStart: $parametersStart,\n'
        'parametersEnd: $parametersEnd,\n'
        'bodyStart: $bodyStart,\n'
        'bodyEnd: $bodyEnd\n'
        '}';
  }

  RawFunctionDeclaration(
    super.identifierStart,
    super.identifierEnd,
    super.identifier,
    this.parametersStart,
    this.parametersEnd,
    this.parameters,
  );
}

class RawVariableDeclaration extends RawDeclaration {
  RawVariableDeclaration(
    super.identifierStart,
    super.identifierEnd,
    super.identifier,
  );

  @override
  String toString() {
    return 'RawVariableDeclaration{\n'
        'identifier: $identifier,\n'
        'identifierStart: $identifierStart,\n'
        'identifierEnd: $identifierEnd,\n'
        'bodyStart: $bodyStart,\n'
        'bodyEnd: $bodyEnd\n'
        '}';
  }
}
