import 'dart:math' as math;
import 'package:extended_math/extended_math.dart';
import '../math/expr.dart';

class ParserOptions {
  final String variableName;
  final bool generateRepsForExpressions;
  final Map<String, double> constants;
  final Map<String, SingleArgumentFunction> functionsWithOneArgument;
  final Map<String, TwoArgumentFunction> functionsWithTwoArguments;

  ParserOptions({
    this.variableName = "x",
    this.generateRepsForExpressions = true,
    this.constants = defaultConstants,
    this.functionsWithOneArgument = defaultFunctionsWithOneArgument,
    this.functionsWithTwoArguments = defaultFunctionsWithTwoArguments,
  });

  static const Map<String, double> defaultConstants = {
    "pi": math.pi,
    "e": math.e,
    "phi": (1 + 2.23606797749979) / 2,
  };
  static const Map<String, SingleArgumentFunction>
      defaultFunctionsWithOneArgument = {
    "sqrt": math.sqrt,
    "sin": math.sin,
    "asin": math.asin,
    "cos": math.cos,
    "acos": math.acos,
    "tan": math.tan,
    "atan": math.atan,
    "ln": math.log,
    "log": _log10,
  };

  static const Map<String, TwoArgumentFunction>
      defaultFunctionsWithTwoArguments = {
    "pow": _pow,
    "root": _root,
    "rt": _root,
    "log": _log,
  };
}

double _pow(i1, i2) => math.pow(i1, i2).toDouble();

double _root(double _num, double n) {
  final num = Number(_num);
  return num.rootOf(n).toDouble();
}

double _log10(double num) {
  return _log(num, 10);
}

double _log(double num, double base) {
  throw UnimplementedError("not implemented");
}

typedef SingleArgumentFunction = double Function(double input);

typedef TwoArgumentFunction = double Function(double input1, double input2);

typedef DynamicArgumentsFunctionEvaluator = double Function(
  double variableValue,
  List<Expr> arguments,
  Function({List<Expr> argumentsAtFault, String message}) errFn,
);

typedef DynamicArgumentsFunctionInitialEvaluator = String? Function(
  List<Expr> arguments,
);

class ArgumentsLengthConstraints {
  final int minLength;
  final int? maxLength;

  ArgumentsLengthConstraints({this.minLength = 0, this.maxLength});
}

class DynamicArgumentsFunction {
  final ArgumentsLengthConstraints? argumentsLengthConstraints;
  final DynamicArgumentsFunctionInitialEvaluator? initialEvaluator;
  final DynamicArgumentsFunctionEvaluator evaluator;

  const DynamicArgumentsFunction({
    this.argumentsLengthConstraints,
    this.initialEvaluator,
    required this.evaluator,
  });

  String? checkForErrorsInArguments(List<Expr> arguments) {
    if (argumentsLengthConstraints != null) {
      if (arguments.length < argumentsLengthConstraints!.minLength) {
        return "at least ${argumentsLengthConstraints!.minLength} arguments are expected, "
            "but only ${arguments.length} arguments were given";
      }
      if (argumentsLengthConstraints!.maxLength != null &&
          arguments.length > argumentsLengthConstraints!.maxLength!) {
        return "a maximum of ${argumentsLengthConstraints!.maxLength}"
            " arguments is expected, "
            "but ${arguments.length} arguments were given";
      }
    }
    return initialEvaluator?.call(arguments);
  }
}
