part of "cached_plot_file_parser.dart";

enum CachedDeclarationStatus {
  notFound,
  found,
  changed,
}

class CachedDeclaration {
  final Set<String> variableReferences, functionReferences;
  final String rawBody;
  int order;
  CachedDeclarationStatus status;

  CachedDeclaration(
    this.rawBody,
    this.status,
    this.order,
  )   : variableReferences = {},
        functionReferences = {};
}

class CachedFunctionDeclaration extends CachedDeclaration {
  final List<String> parameters;
  int get parameterLength => parameters.length;
  final Expression body;
  final EvaluatorFunction? evaluatorFunction;

  CachedFunctionDeclaration({
    required this.parameters,
    required this.body,
    String rawBody = "",
    this.evaluatorFunction,
    CachedDeclarationStatus status = CachedDeclarationStatus.found,
  }) : super(rawBody, status, 0);

  @override
  bool operator ==(Object other) {
    if (other is CachedFunctionDeclaration &&
        runtimeType == other.runtimeType &&
        body == other.body) {
      if (other.parameterLength != parameterLength) {
        return false;
      }
      for (var i = 0; i < parameterLength; i++) {
        if (other.parameters[i] != parameters[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'CachedFunctionDeclaration{parameters: $parameters, body: $body, '
        'evaluatorFunction: $evaluatorFunction}';
  }

  @override
  int get hashCode =>
      parameters.hashCode ^ body.hashCode ^ evaluatorFunction.hashCode;

  CachedFunctionDeclaration copy() {
    return CachedFunctionDeclaration(
      parameters: parameters,
      body: body,
      rawBody: rawBody,
      evaluatorFunction: evaluatorFunction,
      status: status,
    )..order = order;
  }
}

class CachedVariableDeclaration extends CachedDeclaration {
  final double value;

  CachedVariableDeclaration({
    required this.value,
    String rawBody = "",
    CachedDeclarationStatus status = CachedDeclarationStatus.found,
  }) : super(rawBody, status, 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedVariableDeclaration &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  String toString() {
    return 'CachedVariableDeclaration{value: $value}';
  }

  @override
  int get hashCode => value.hashCode;

  CachedVariableDeclaration copy() {
    return CachedVariableDeclaration(
      rawBody: rawBody,
      status: status,
      value: value,
    )..order = order;
  }
}
