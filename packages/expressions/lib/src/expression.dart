/// represents a mathematical expression
abstract class Expression {
  Set<String> get referencedVariables;
  Set<String> get referencedFunctions;
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
  Set<String> get referencedVariables => {};
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
}
