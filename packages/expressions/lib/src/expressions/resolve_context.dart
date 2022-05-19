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

/// a context for simplifying an [Expression],
/// by giving context to the variables, functions, and operators used.
///
/// used in [Expression.resolve] and [Expression.resolveToNumber],
/// however for [Expression.resolveToNumber] all variables
/// and functions have to be given
/// (the function either from [callFunction] or [insertFunction])
///
/// how resolving in [Expression.resolve] works:
///
/// in the expression a variable [Variable] can be resolved,
/// if [getVariableValue] yields a non null value
/// for the variable name in question.
///
/// an operator [OperatorCall] can be resolved, if both its operands
/// were successfully resolved to a [Number] (or are already a [Number]),
/// then [callOperator] is called and if it yields a non null value.
/// if the two operands were not resolved to a [Number],
/// other resolving can still be applied.
///
/// a function [FunctionCall] can be resolved via [callFunction],
/// if all the arguments it has been given,
/// have all been resolved to a [Number], it is then called like [callOperator].
/// if the arguments are still not all converted to [Number]s,
/// [insertFunction] is called, if it then yields a non null value,
/// this is resolved and used.
abstract class ResolveContext {
  /// call a operator [operator] with [operand1] and [operand2],
  /// each non null result will be interpreted,
  /// as the result of an existing operator
  double? callOperator(String operator, double operand1, double operand2);

  /// call the function [name] with the [values] as args,
  /// each non null result will be interpreted,
  /// as the result of an existing function.
  ///
  /// if the function [name] could not be converted
  /// to a [double] input and [double] output callback function,
  /// or if the function reference might contain arguments,
  /// that could not be resolved to a [Number],
  /// also make sure the function is reachable by [insertFunction].
  ///
  /// a function can be called in [callFunction] and [insertFunction],
  /// the resolving however always
  /// first checks [callFunction] and then [insertFunction].
  double? callFunction(String name, List<double> values);

  /// insert the list of arguments ([expressions]) into an [Expression],
  /// where that [Expression] represents a function that is being inserted into.
  ///
  /// how the arguments are inserted into the [Expression],
  /// should be for concrete variables,
  /// where there is a concrete order of those variables
  /// in the parameter list of the function.
  ///
  /// the [Expression] that is inserted in, should be copied.
  ///
  /// it is possible for the [Expression] that is inserted into,
  /// to still have left over [Variable]s that have not be inserted away,
  /// this is expected, in the resolving however,
  /// these will also be tried to resolve
  /// (and if that does not succeed in [Expression.resolveToNumber],
  /// an error will be thrown)
  Expression? insertFunction(
    String name,
    List<Expression> expressions,
  );
  double? getVariableValue(String name);

  /// default [ResolveContext] implementation only containing operators.
  ///
  /// contains operators: +, -, *, /, ^
  const factory ResolveContext.defaults() = _DefaultSimplifyContext;

  /// only contains operators from [ResolveContext.defaults],
  /// but callable functions can be added with [functions],
  /// insert functions with [insertFunctions]
  /// variables with [variables], and operators can be added
  /// (or overridden) with [operators].
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
