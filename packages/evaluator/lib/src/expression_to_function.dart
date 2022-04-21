import 'package:evaluator/src/evaluator.dart';
import 'package:expressions/expressions.dart';

/// convert an [Expression] to an efficient [EvaluatorFunction],
/// which is a callable function, that can be called with a [double]
/// and gives back a [double],
/// this therefore allows to evaluate math_functions functions, such as f(x) = x^2.
///
/// the function does not care what the variable name is,
/// it substitutes all variables with the input from the [EvaluatorFunction].
///
/// all functions and operators that are needed have to be provided
/// by the [EvaluatorContext], as it does not provide a way to check,
/// if the function exists.
///
/// to check for any mistakes use [Expression.referencedVariables],
/// [Expression.referencedFunctions] or
/// give the available functions and variables
/// to the [ExpressionParser] via [ParserContext].
///
/// please also note that [expressionToEvaluatorFunction] does not simplify
/// the functions, to achieve the most efficient functions,
/// use [Expression.simplify] to first get a simplified function
///
/// to evaluate [FunctionCall]s that should reference other [Expression]s,
/// use [Expression.insert]
///
/// the evaluate function can not only evaluate to [double.nan],
/// but also [double.infinity] or [double.negativeInfinity]
EvaluatorFunction expressionToEvaluatorFunction(
  Expression e, [
  EvaluatorContext c = const EvaluatorContext(),
]) {
  if (e is Number) {
    return (_) => e.value;
  } else if (e is OperatorCall) {
    return _operatorCallToEvaluatorFunction(e, c);
  } else if (e is FunctionCall) {
    return _functionCallToEvaluatorFunction(e, c);
  } else if (e is NegateOperator) {
    final evalFunction = expressionToEvaluatorFunction(e.expression, c);
    return (v) => -evalFunction(v);
  } else {
    return (v) => v;
  }
}

EvaluatorFunction _operatorCallToEvaluatorFunction(
  OperatorCall e, [
  EvaluatorContext c = const EvaluatorContext(),
]) {
  final evalFunction1 = expressionToEvaluatorFunction(e.expression1, c);
  final evalFunction2 = expressionToEvaluatorFunction(e.expression2, c);
  final operator = c.getOperator(e.operator);
  return (v) => operator(evalFunction1(v), evalFunction2(v));
}

EvaluatorFunction _functionCallToEvaluatorFunction(
  FunctionCall e, [
  EvaluatorContext c = const EvaluatorContext(),
]) {
  if (e.arguments.length == 1) {
    final oneArgumentFunction = c.getOneArgumentFunction(e.name);
    final evalFunction = expressionToEvaluatorFunction(e.arguments[0], c);
    return (v) => oneArgumentFunction(evalFunction(v));
  } else if (e.arguments.length == 2) {
    final evalFunction1 = expressionToEvaluatorFunction(e.arguments[0], c);
    final evalFunction2 = expressionToEvaluatorFunction(e.arguments[1], c);
    final twoArgumentFunction = c.getTwoArgumentFunction(e.name);
    return (v) => twoArgumentFunction(evalFunction1(v), evalFunction2(v));
  } else {
    final evalFunctions = e.arguments
        .map((argument) => expressionToEvaluatorFunction(argument, c))
        .toList(growable: false);
    final multipleArgumentFunction = c.getMultipleArgumentFunction(e.name);
    return (v) => multipleArgumentFunction(
        evalFunctions.map((e) => e(v)).toList(growable: false));
  }
}
