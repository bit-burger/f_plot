import 'package:f_plot/domain/math_function.dart';
import 'package:math_keyboard/math_keyboard.dart';

import 'math_function_evaluation_repository_contract.dart';

class MathFunctionEvaluationRepository
    implements IMathFunctionEvaluationRepository {
  @override
  Map<String, MathFunctionEvaluationResult> evaluateMathFunctions(
    List<MathFunction> functions,
    List<double> xPoints,
  ) {
    for (MathFunction function in functions) {
      function.
    }
  }
}
