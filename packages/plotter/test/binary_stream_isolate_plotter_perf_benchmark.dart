import 'dart:math';

import 'package:evaluator/evaluator.dart';
import 'package:expressions/expressions.dart';
import 'package:plotter/src/binary_stream_isolate_plotter.dart';

void main() {
  late final BinaryStreamIsolatePlotter plotter;
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
    plotter = BinaryStreamIsolatePlotter(
      rangeBegin: -1024,
      rangeEnd: 1024,
      howManyDivides: 10,
      afterHowManyEventsNewStreamEvent: pow(2, 53).toInt(),
      maxRangeWithOneIsolate: 1024,
      functions: {"a": functionA, "b": functionB},
    );
  }

  {
    final stopWatch = Stopwatch()..start();
    print("started stop watch");
    plotter.beginComputation();
    plotter.stream.listen((event) {}, onDone: () {
      stopWatch.stop();
      print("stopped at ${stopWatch.elapsedMilliseconds / 1000} seconds");
    });
  }
}
