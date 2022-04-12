import 'dart:math';

typedef EvaluatorFunction = double Function(double x);

typedef OneArgumentFunction = double Function(double a);
typedef TwoArgumentFunction = double Function(double a, double b);
typedef MultipleArgumentFunction = double Function(List<double> ls);

abstract class EvaluatorContext {
  OneArgumentFunction getOneArgumentFunction(String name);
  TwoArgumentFunction getTwoArgumentFunction(String name);
  MultipleArgumentFunction getMultipleArgumentFunction(String name);
  TwoArgumentFunction getOperator(String name);

  const factory EvaluatorContext({
    Map<String, OneArgumentFunction> oneArgumentFunctions,
    Map<String, TwoArgumentFunction> twoArgumentFunctions,
    Map<String, MultipleArgumentFunction> multipleArgumentFunctions,
    Map<String, TwoArgumentFunction> operators,
  }) = _SimpleEvaluatorContext;
}

class _SimpleEvaluatorContext implements EvaluatorContext {
  final Map<String, OneArgumentFunction> oneArgumentFunctions;
  final Map<String, TwoArgumentFunction> twoArgumentFunctions;
  final Map<String, MultipleArgumentFunction> multipleArgumentFunctions;
  final Map<String, TwoArgumentFunction> operators;

  const _SimpleEvaluatorContext({
    this.oneArgumentFunctions = const {},
    this.twoArgumentFunctions = const {},
    this.multipleArgumentFunctions = const {},
    this.operators = const {
      "+": _plus,
      "-": _minus,
      "*": _multiply,
      "/": _divide,
      "^": _pow,
    },
  });

  static double _plus(double a, double b) => a + b;
  static double _minus(double a, double b) => a - b;
  static double _multiply(double a, double b) => a * b;
  static double _divide(double a, double b) => a / b;
  static double _pow(double a, double b) => pow(a, b) as double;

  @override
  OneArgumentFunction getOneArgumentFunction(String name) {
    return oneArgumentFunctions[name]!;
  }

  @override
  TwoArgumentFunction getTwoArgumentFunction(String name) {
    return twoArgumentFunctions[name]!;
  }

  @override
  MultipleArgumentFunction getMultipleArgumentFunction(String name) {
    return multipleArgumentFunctions[name]!;
  }

  @override
  TwoArgumentFunction getOperator(String name) {
    return operators[name]!;
  }
}
