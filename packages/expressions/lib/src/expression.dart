abstract class Expression {}

class Number extends Expression {
  final double value;

  Number(this.value);

  @override
  bool operator ==(Object other) => other is Number && value == other.value;

  @override
  String toString() {
    return value.toString();
  }
}

class VariableReference extends Expression {
  final String name;

  VariableReference(this.name);

  @override
  bool operator ==(Object other) =>
      other is VariableReference && name == other.name;

  @override
  String toString() {
    return name;
  }
}

class FunctionCall extends Expression {
  final String name;
  final List<Expression> arguments;

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
}

bool _listsAreEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class OperatorCall extends Expression {
  final String operator;
  final Expression expression1, expression2;

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
}
