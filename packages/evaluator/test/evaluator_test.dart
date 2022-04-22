import 'dart:math';

import 'package:evaluator/evaluator.dart';
import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

EvaluatorFunction evaluate(
  String s, [
  EvaluatorContext c = const EvaluatorContext(),
]) {
  final parser = StringExpressionParser();
  final parsed = parser.parse(s);
  return expressionToEvaluatorFunction(parsed, c);
}

void main() {
  group('evaluate constants', () {
    test('simple addition', () {
      final f = evaluate("4 + 1.");
      expect(f(-1), 5);
      expect(f(0), 5);
      expect(f(1), 5);
    });
  });

  group("evaluate variables", () {
    test('simple variables', () {
      final f = evaluate("4+x/-2");
      expect(f(-1), 4.5);
      expect(f(0), 4);
      expect(f(1), 3.5);
    });

    test('nan test', () {
      final f = evaluate("x/ 0.");
      expect(f(-1), double.negativeInfinity);
      expect(f(0).isNaN, isTrue);
      expect(f(1), double.infinity);
    });

    test('complicated variables', () {
      final f = evaluate("x^2 + x + 1");
      expect(f(-1), 1);
      expect(f(0), 1);
      expect(f(1), 3);
    });
  });

  group("evaluate functions", () {
    test('complicated variables', () {
      final f = evaluate(
        "timesHalf (addAll(1, x, 5), sqrt(x))",
        EvaluatorContext(
          oneArgumentFunctions: {
            "sqrt": (a) => sqrt(a),
          },
          twoArgumentFunctions: {
            "timesHalf": (a, b) => a * b * (1 / 2),
          },
          multipleArgumentFunctions: {
            "addAll": (vals) => vals[0] + vals[1] + vals[2],
          },
        ),
      );
      expect(f(-1).isNaN, isTrue);
      expect(f(0), 0);
      expect(f(4), 10);
    });
  });
}
