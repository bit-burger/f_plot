import 'package:expressions/src/expressions/resolve_context.dart';
import 'package:expressions/src/parsing/string_expression_parser/parser.dart';

/// represents a mathematical expression
abstract class Expression {
  static final _stringExpressionParser = StringExpressionParser();

  /// a shortcut to parse an [Expression] from a [String],
  /// using a [StringExpressionParser] without giving any context,
  /// only standard operators are allowed.
  ///
  /// can throw a [StringExpressionParseError]
  factory Expression.fromString(String s) {
    return _stringExpressionParser.parse(s);
  }

  Expression();

  Set<String> get referencedVariables;
  Set<String> get referencedFunctions;

  /// [resolve] with defaults.
  Expression simplify() {
    return resolve(const ResolveContext.defaults());
  }

  /// the [Expression] will resolve and simplify itself as much as possible,
  /// with the functions and variables given by [c].
  ///
  /// the [Expression] will modify itself (and give itself back)
  /// or give back an alternative expression.
  ///
  /// if [overriddenVariables] are given, every variable contained in them,
  /// will not be replaced by a variable, even if it is found inside of of [c].
  ///
  /// if a function in [c] is called with the wrong amount of parameters,
  /// be it a inserted or callable function, this *can* throw an error.
  ///
  /// example:
  ///   context:
  ///     given variables:
  ///       a = 4
  ///       b = 9
  ///     given functions:
  ///       c(x,y) = x * y + b
  ///   expression:
  ///     c(a * 2, d)
  ///   simplified version:
  ///     8 * d + 9
  ///
  /// for more information see: [ResolveContext]
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]);

  /// [resolveToNumber] with defaults.
  double simplifyToNumber() {
    return resolveToNumber(const ResolveContext.defaults());
  }

  /// resolve to a [double] using the functions and variables given by [c],
  /// without modifying the current [Expression].
  ///
  /// if the expression cannot be resolved using to a single number [c],
  /// a [StateError] is thrown.
  ///
  /// instead use the [resolve] method and check with [isNumber],
  /// if it was able to simplify the expression to a number
  /// and use [numberValue] if true
  ///
  /// if a function in [c] is called with the wrong amount of parameters,
  /// be it a inserted or callable function, this *can* throw an error
  double resolveToNumber(ResolveContext c);

  /// copies the [Expression]s by [variables] into the correct variables
  /// of a copied version of the current expression
  Expression copyWithInsertVariables(Map<String, Expression> variables);

  /// all methods [isNegative], [negated], [isNumber], and [numberValue],
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

  /// exact copy of [Expression]
  Expression copy();
}

/// represents a number literal with the value of [value]
class Number extends Expression {
  double value;

  Number(this.value);

  @override
  bool operator ==(Object other) => other is Number && value == other.value;

  @override
  String toString() {
    if (value.toInt().compareTo(value) == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Set<String> get referencedFunctions => {};

  @override
  Set<String> get referencedVariables => {};

  @override
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]) =>
      this;

  @override
  double resolveToNumber(ResolveContext c) => value;

  @override
  Expression copyWithInsertVariables(Map<String, Expression> variables) =>
      copy();

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

  @override
  Expression copy() => Number(value);
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
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]) {
    if (overriddenVariables.contains(name)) {
      return this;
    }
    final substituteValue = c.getVariableValue(name);
    if (substituteValue != null) {
      return Number(substituteValue);
    }
    return this;
  }

  @override
  double resolveToNumber(ResolveContext c) {
    final value = c.getVariableValue(name);
    if (value == null) {
      throw StateError("All variables need to be contained "
          "in the ResolveContext 'c', variable '$name' is not contained");
    }
    return value;
  }

  @override
  Expression copyWithInsertVariables(Map<String, Expression> variables) =>
      variables[name]?.copy() ?? copy();

  @override
  bool isNegative() => false;

  @override
  Expression negated() => throw UnimplementedError();

  @override
  bool isNumber() => false;

  @override
  double numberValue() => throw UnimplementedError();

  @override
  Expression copy() => Variable(name);
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
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]) {
    // first resolve all arguments (therefore modifying the current expression)
    arguments = arguments
        .map((expression) => expression.resolve(c, overriddenVariables))
        .toList(growable: false);
    // check if all arguments were resolved to numbers
    final allArgumentsNumber =
        arguments.every((expression) => expression.isNumber());
    if (allArgumentsNumber) {
      // if all arguments are a number, try to call a function
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
    // if function exists as an Expression, return the inserted function,
    // else return the current FunctionCall
    // (which is however modified, see first comment)
    final insertFunctionResult = c.insertFunction(name, arguments);
    return insertFunctionResult?.resolve(c, overriddenVariables) ?? this;
  }

  @override
  double resolveToNumber(ResolveContext c) {
    final numberArguments = this
        .arguments
        .map((expression) => expression.resolveToNumber(c))
        .toList(growable: false);
    final callFunctionResult = c.callFunction(name, numberArguments);
    if (callFunctionResult != null) {
      return callFunctionResult;
    }
    final arguments = numberArguments
        .map((expression) => Number(expression))
        .toList(growable: false);
    final insertFunctionResult = c.insertFunction(name, arguments);
    if (insertFunctionResult == null) {
      throw StateError("All variables need to be contained "
          "in the ResolveContext 'c', "
          "either as a insert function or a callable function, "
          "function'$name' is not contained");
    }
    return insertFunctionResult.resolveToNumber(c);
  }

  @override
  Expression copyWithInsertVariables(Map<String, Expression> variables) {
    // does not make much sense to insert the variables into a function,
    // that has not been simplified/resolved
    //
    // to prevent this, first resolve the current expression
    final expressionCopy = copy();
    expressionCopy.arguments = expressionCopy.arguments
        .map((expression) => expression.copyWithInsertVariables(variables))
        .toList(growable: false);
    return expressionCopy;
  }

  @override
  bool isNegative() => false;

  @override
  Expression negated() => throw UnimplementedError();

  @override
  bool isNumber() => false;

  @override
  double numberValue() => throw UnimplementedError();

  // needs to be of type FunctionCall, so copyInsertVariables can use its result
  @override
  FunctionCall copy() => FunctionCall(
        name,
        arguments
            .map((expression) => expression.copy())
            .toList(growable: false),
      );
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
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]) {
    expression1 = expression1.resolve(c, overriddenVariables);
    expression2 = expression2.resolve(c, overriddenVariables);
    if (expression1.isNumber() && expression2.isNumber()) {
      final n1 = expression1.numberValue();
      final n2 = expression2.numberValue();
      final result = c.callOperator(operator, n1, n2);
      if (result != null) {
        return Number(result);
      }
    }
    if (operator == "/" || operator == "*") {
      if (expression1.isNegative() && expression2.isNegative()) {
        expression1 = expression1.negated();
        expression2 = expression2.negated();
      }
    } else if (operator == "-" || operator == "+") {
      if (expression2.isNegative()) {
        expression1 = expression1;
        expression2 = expression2.negated();
        operator = operator == "+" ? "-" : "+";
      }
    }
    return this;
  }

  @override
  double resolveToNumber(ResolveContext c) {
    final value1 = expression1.resolveToNumber(c);
    final value2 = expression2.resolveToNumber(c);
    final result = c.callOperator(operator, value1, value2);
    if (result == null) {
      throw StateError("All operators need to be contained "
          "in the ResolveContext 'c', operator '$operator' is not contained");
    }
    return result;
  }

  @override
  Expression copyWithInsertVariables(Map<String, Expression> variables) =>
      OperatorCall(
        operator,
        expression1.copyWithInsertVariables(variables),
        expression2.copyWithInsertVariables(variables),
      );

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

  @override
  Expression copy() => OperatorCall(
        operator,
        expression1.copy(),
        expression2.copy(),
      );
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
  Expression resolve(
    ResolveContext c, [
    Iterable<String> overriddenVariables = const {},
  ]) {
    expression = expression.resolve(c, overriddenVariables);
    if (expression.isNumber() || expression.isNegative()) {
      return expression.negated();
    }
    return this;
  }

  @override
  double resolveToNumber(ResolveContext c) => -expression.resolveToNumber(c);

  @override
  Expression copyWithInsertVariables(Map<String, Expression> variables) =>
      NegateOperator(expression.copyWithInsertVariables(variables));

  @override
  bool isNegative() => true;

  /// expects number to already been simplified away
  /// into negative number, as per documentation in [Expression.isNumber]
  @override
  bool isNumber() => false;

  @override
  Expression negated() => expression;

  @override
  double numberValue() => throw UnimplementedError();

  @override
  Expression copy() => NegateOperator(expression.copy());
}
