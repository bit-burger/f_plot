import 'package:f_plot/domain/math_function.dart';
// import 'package:math_keyboard/src/foundation/node.dart';

part 'error.dart';
part 'result.dart';

// class RawFunction {
//   final String name;
//   final List<String> args;
//   final TeXNode body;
//
//   const RawFunction({
//     required this.name,
//     required this.args,
//     required this.body,
//   });
// }

abstract class IMathFunctionEvaluationRepository {
  // List<String?> checkFunctionsSyntax(List<RawFunction> functions);
  Map<String, MathFunctionEvaluationResult> evaluateMathFunctions(
    List<MathFunction> functions,
    List<double> xPoints,
  );
}
