part of 'math_function_evaluation_repository_contract.dart';

class MathFunctionEvaluationError {
  final List<String> invalidVariableReferences;
  final List<String> errorMessages;

  MathFunctionEvaluationError(
    this.invalidVariableReferences,
    this.errorMessages,
  );
}
