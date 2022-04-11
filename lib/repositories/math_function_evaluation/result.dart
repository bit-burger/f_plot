part of "math_function_evaluation_repository_contract.dart";

class MathFunctionEvaluationResult {
  final List<String>? errors;
  final Map<double, double>? values;

  MathFunctionEvaluationResult({this.errors, this.values}) {
    assert((errors == null) != (values == null));
  }

  bool get hasError => errors != null;

  List<String> get asError => errors!;
  Map<double, double>? get asValues => values!;
}
