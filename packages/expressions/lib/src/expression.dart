import 'dart:math' as math;

typedef SimplifyFunction = double Function(List<double> values);
typedef SimplifyOperator = double Function(double val1, double val2);

class _CustomSimplifyContext extends _CustomFunctionsSimplifyContext {
  final Map<String, SimplifyOperator> operators;

  const _CustomSimplifyContext(
      Map<String, SimplifyFunction> functions, this.operators)
      : super(functions);
}

class _CustomFunctionsSimplifyContext extends _DefaultSimplifyContext {
  final Map<String, SimplifyFunction> functions;

  const _CustomFunctionsSimplifyContext([this.functions = const {}]);

  @override
  double? callFunction(String name, List<double> values) {
    return functions[name]?.call(values);
  }
}

class _DefaultSimplifyContext implements SimplifyContext {
  const _DefaultSimplifyContext();

  @override
  double? callFunction(String name, List<double> values) => null;

  @override
  double? callOperator(String operator, double operand1, double operand2) {
    switch (operator) {
      case "+":
        return operand1 + operand2;
      case "-":
        return operand1 - operand2;
      case "*":
        return operand1 * operand2;
      case "/":
        return operand1 / operand2;
      case "^":
        return math.pow(operand1, operand2) as double;
    }
  }
}

/// a context for simplifying an expression,
/// if a function or an operator is called exclusively with literals,
/// the appropriate function or operator will be called.
///
/// if the result of that call is not null, the [Expression.simplify] call,
/// will give back a [Number] instead of itself
abstract class SimplifyContext {
  double? callFunction(String name, List<double> values);
  double? callOperator(String operator, double operand1, double operand2);

  const factory SimplifyContext.defaults() = _DefaultSimplifyContext;

  const factory SimplifyContext.customFunctions(
          Map<String, SimplifyFunction> functions) =
      _CustomFunctionsSimplifyContext;

  factory SimplifyContext.custom(Map<String, SimplifyFunction> functions,
      Map<String, SimplifyOperator> operators) = _CustomSimplifyContext;
}

/// represents a mathematical expression
abstract class Expression {
  Set<String> get referencedVariables;
  Set<String> get referencedFunctions;

  Expression simplifyWithDefaults() {
    return simplify(const _DefaultSimplifyContext());
  }

  /// the [Expression] will modify itself (and give itself back)
  /// or give back an alternative expression,
  /// in both cases the given back expression will try to be simplified
  Expression simplify(SimplifyContext c);

  /// all methods under [simplify],
  /// expect [Expression] to already have been simplified

  /// returns true on a negative [Number], a [NegateOperator] and
  /// if the conditions are met, on a [OperatorCall] (e.g: -a-a or -b*a)
  bool isNegative();

  /// returns the negated version of the called [Expression].
  ///
  /// only call if [isNegative] has given back true
  Expression negated();

  /// return true if the [Expression] is a [Number]
  bool isNumber();

  /// will only give back a [double] if the [Expression] is of type [Number],
  /// else it will throw a [UnimplementedError]
  double numberValue();
}

/// represents a number literal with the value of [value]
class Number extends Expression {
  double value;

  Number(this.value);

  @override
  bool operator ==(Object other) => other is Number && value == other.value;

  @override
  String toString() {
    return value.toString();
  }

  @override
  Set<String> get referencedFunctions => {};

  @override
  Set<String> get referencedVariables => {};

  @override
  Expression simplify(SimplifyContext c) => this;

  @override
  bool isNegative() => value.isNegative;

  @override
  Expression negated() {
    value = -value;
    return this;
  }

  @override
  bool isNumber() => true;

  @override
  double numberValue() => value;
}

/// represents a variable reference with the variable name being [name]
class Variable extends Expression {
  String name;

  Variable(this.name);

  @override
  bool operator ==(Object other) => other is Variable && name == other.name;

  @override
  String toString() {
    return name;
  }

  @override
  Set<String> get referencedFunctions => {};

  @override
  Set<String> get referencedVariables => {name};

  @override
  Expression simplify(SimplifyContext c) => this;

  @override
  bool isNegative() => false;

  @override
  Expression negated() => throw UnimplementedError();

  @override
  bool isNumber() => false;

  @override
  double numberValue() => throw UnimplementedError();
}

/// represents a function call, such as f(1).
///
/// name of the function is [name] and
/// the function arguments are a list of expressions
class FunctionCall extends Expression {
  String name;
  List<Expression> arguments;

  FunctionCall(this.name, this.arguments);

  @override
  bool operator ==(Object other) =>
      other is FunctionCall &&
      name == other.name &&
      _listsAreEqual(arguments, other.arguments);

  @override
  String toString() {
    return "$name(${arguments.join(",")})";
  }

  @override
  Set<String> get referencedFunctions {
    final functions = {name};
    for (final argument in arguments) {
      functions.addAll(argument.referencedFunctions);
    }
    return functions;
  }

  @override
  Set<String> get referencedVariables {
    final variables = <String>{};
    for (final argument in arguments) {
      variables.addAll(argument.referencedVariables);
    }
    return variables;
  }

  @override
  Expression simplify(SimplifyContext c) {
    arguments = arguments
        .map((expression) => expression.simplify(c))
        .toList(growable: false);
    if (arguments.every((expression) => expression.isNumber())) {
      final result = c.callFunction(
        name,
        arguments
            .map((expression) => expression.numberValue())
            .toList(growable: false),
      );
      if (result != null) {
        return Number(result);
      }
    }
    return this;
  }

  @override
  bool isNegative() => false;

  @override
  Expression negated() => throw UnimplementedError();

  @override
  bool isNumber() => false;

  @override
  double numberValue() => throw UnimplementedError();
}

bool _listsAreEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// represents an operator call such as 1 + pi, where + is the [operator],
/// 1 is expression1 and pi is expression2
class OperatorCall extends Expression {
  String operator;
  Expression expression1, expression2;

  OperatorCall(this.operator, this.expression1, this.expression2);

  @override
  bool operator ==(Object other) =>
      other is OperatorCall &&
      operator == other.operator &&
      expression1 == other.expression1 &&
      expression2 == other.expression2;

  @override
  String toString() {
    return "($expression1$operator$expression2)";
  }

  @override
  Set<String> get referencedFunctions =>
      expression1.referencedFunctions.union(expression2.referencedFunctions);

  @override
  Set<String> get referencedVariables =>
      expression1.referencedVariables.union(expression2.referencedVariables);

  @override
  Expression simplify(SimplifyContext c) {
    final e1 = expression1.simplify(c);
    final e2 = expression2.simplify(c);
    if (e1.isNumber() && e2.isNumber()) {
      final n1 = e1.numberValue();
      final n2 = e2.numberValue();
      final result = c.callOperator(operator, n1, n2);
      if (result != null) {
        return Number(result);
      }
    }
    if (operator == "/" || operator == "*") {
      if (e1.isNegative() && e2.isNegative()) {
        expression1 = e1.negated();
        expression2 = e2.negated();
      }
    } else if (operator == "-" || operator == "+") {
      if (e2.isNegative()) {
        expression1 = e1;
        expression2 = e2.negated();
        operator = operator == "+" ? "-" : "+";
      }
    }
    return this;
  }

  @override
  bool isNegative() {
    final n1 = expression1.isNegative();
    final n2 = expression2.isNegative();
    if (operator == "/" || operator == "*") {
      return n1 != n2;
    } else if (operator == "-") {
      return n1 && !n2;
    }
    return false;
  }

  @override
  Expression negated() {
    if (operator == "/" || operator == "*") {
      if (expression1.isNegative()) {
        expression1 = expression1.negated();
      } else {
        expression2 = expression2.negated();
      }
      return this;
    } else if (operator == "-") {
      expression1 = expression1.negated();
      operator = "+";
      return this;
    }
    throw UnimplementedError();
  }

  @override
  bool isNumber() => false;

  @override
  double numberValue() => throw UnimplementedError();
}

/// negate [expression]
class NegateOperator extends Expression {
  Expression expression;

  NegateOperator(this.expression);

  @override
  bool operator ==(Object other) =>
      other is NegateOperator && expression == other.expression;

  @override
  String toString() {
    return "-($expression)";
  }

  @override
  Set<String> get referencedFunctions => expression.referencedFunctions;

  @override
  Set<String> get referencedVariables => expression.referencedVariables;

  @override
  bool isNegative() => true;

  // expects number to already been simplified away
  // into negative number
  @override
  bool isNumber() => false;

  @override
  Expression negated() => expression;

  @override
  double numberValue() => throw UnimplementedError();

  @override
  Expression simplify(SimplifyContext c) {
    expression = expression.simplify(c);
    if (expression.isNumber() || expression.isNegative()) {
      return expression.negated();
    }
    return this;
  }
}
