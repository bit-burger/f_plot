import 'dart:math';

import 'package:evaluator/evaluator.dart';
import 'package:expressions/expressions.dart';
import 'package:plotter/src/linear_asynchronous_isolate_plotter.dart';

void main() async {
  late final LinearAsynchronousIsolatePlotter plotter;
  {
    final parser = RegularStringExpressionParser();
    final EvaluatorFunction functionA, functionB;
    {
      const rawFunctionA = "(1/4)*x^3 + 12*x^5";
      var functionExpressionA = parser.parse(rawFunctionA);
      functionExpressionA = functionExpressionA.simplifyWithDefaults();
      functionA = expressionToEvaluatorFunction(functionExpressionA);
    }
    {
      const rawFunctionB = "(1/4)*x^3 + 12*x^5 + sqrt(sqrt(x))*(x^x) "
          "+ x*x*x*x - x*x*x*x*x +x*x*x*x*x*x -x*x*x*x*x";
      var functionExpressionB = parser.parse(rawFunctionB);
      functionExpressionB = functionExpressionB.simplifyWithDefaults();
      functionB = expressionToEvaluatorFunction(
        functionExpressionB,
        EvaluatorContext(
          oneArgumentFunctions: {"sqrt": (v) => sqrt(v)},
        ),
      );
    }
    plotter = LinearAsynchronousIsolatePlotter(
      beginX: -1024,
      lastX: 1024,
      stepSizeX: 1 / pow(2, 10),
      functions: {"a": functionA, "b": functionB},
    );
  }

  {
    final stopWatch = Stopwatch()..start();
    print("started stop watch");
    await plotter.compute();
    stopWatch.stop();
  }
}
