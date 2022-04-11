import 'expression.dart';

/// a parser should parse the [ParseType] into an Expression.
abstract class ExpressionParser<ParseType> {
  Expression parse(ParseType rawExpression, [ParserContext c]);
}

/// if a [ParserContext] is provided,
/// this gives the [ExpressionParser.parse] method more things it can check.
///
/// it can now also check if a variable can be referenced,
/// if a function can be called
/// and with how many arguments the function should be called
abstract class ParserContext {
  /// gives back how many arguments a given function can have,
  /// gives back null, if function does not exist
  int? allowedFunctionParameterCount(String f);

  /// gives back if a variable exists and can be referenced
  bool variableAllowed(String v);
}

class SimpleParserContext implements ParserContext {
  final Map<String, int> allowedFunctions;
  final Set<String> allowedVariables;

  const SimpleParserContext(this.allowedFunctions, this.allowedVariables);

  @override
  int? allowedFunctionParameterCount(String f) {
    return allowedFunctions[f];
  }

  @override
  bool variableAllowed(String v) {
    return allowedVariables.contains(v);
  }
}
