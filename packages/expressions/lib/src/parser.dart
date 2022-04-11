import 'expression.dart';

/// a parser should parse the [ParseType] into an Expression.
abstract class ExpressionParser<ParseType> {
  Expression parse(ParseType rawExpression);
}
