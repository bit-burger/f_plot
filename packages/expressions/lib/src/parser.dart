import 'expression.dart';

abstract class ExpressionParser<ParseType> {
  Expression parse(ParseType rawExpression);
}
