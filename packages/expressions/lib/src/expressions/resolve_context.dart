import 'dart:math' as math;

import '../../expressions.dart';

typedef ResolveFunction = double Function(List<double> values);
typedef ResolveOperator = double Function(double val1, double val2);

class ExpressionInsertFunction {
  final List<String> parameterNames;
  final Expression expression;

  ExpressionInsertFunction({
    required this.parameterNames,
    required this.expression,
  });
}

/// a context for simplifying an expression,
/// if a function or an operator is called exclusively with literals,
/// the appropriate function or operator will be called.
///
/// if the result of that call is not null, the [Expression.resolve] call,
/// will give back a [Number] instead of itself
abstract class ResolveContext {
  double? callOperator(String operator, double operand1, double operand2);
  double? callFunction(String name, List<double> values);
  Expression? insertFunction(
    String name,
    List<Expression> expressions,
  );
  double? getVariableValue(String name);

  const factory ResolveContext.defaults() = _DefaultSimplifyContext;

  factory ResolveContext.custom({
    Map<String, ResolveOperator> operators,
    Map<String, ResolveFunction> functions,
    Map<String, double> variables,
    Map<String, ExpressionInsertFunction> insertFunctions,
  }) = _CustomSimplifyContext;
}

class _CustomSimplifyContext extends _DefaultSimplifyContext {
  final Map<String, ResolveOperator> operators;
  final Map<String, ResolveFunction> functions;
  final Map<String, double> variables;
  final Map<String, ExpressionInsertFunction> insertFunctions;

  const _CustomSimplifyContext({
    this.operators = const {},
    this.functions = const {},
    this.variables = const {},
    this.insertFunctions = const {},
  });

  @override
  double? callFunction(String name, List<double> values) {
    return functions[name]?.call(values);
  }

  @override
  double? callOperator(String operator, double operand1, double operand2) {
    return operators[operator]?.call(operand1, operand2) ??
        super.callOperator(operator, operand1, operand2);
  }

  @override
  double? getVariableValue(String name) {
    return variables[name];
  }

  @override
  Expression? insertFunction(String name, List<Expression> expressions) {
    final insertFunction = insertFunctions[name];
    if (insertFunction == null) {
      return null;
    }
    final variables = {
      for (var i = 0; i < insertFunction.parameterNames.length; i++)
        insertFunction.parameterNames[i]: expressions[i]
    };
    return insertFunction.expression.copyWithInsertVariables(variables);
  }
}

class _DefaultSimplifyContext implements ResolveContext {
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
    return null;
  }

  @override
  Expression? insertFunction(String name, List<Expression> expressions) => null;

  @override
  double? getVariableValue(String name) => null;
}
