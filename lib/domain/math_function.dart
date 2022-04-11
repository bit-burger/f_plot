import "package:math_expressions/math_expressions.dart" hide MathFunction;

class MathFunction {
  final String name;
  final List<String> arguments;
  final Expression body;

  const MathFunction({
    required this.name,
    required this.arguments,
    required this.body,
  });
}
