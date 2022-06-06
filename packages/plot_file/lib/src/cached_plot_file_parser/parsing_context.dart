part of "cached_plot_file_parser.dart";

class _ParsingContext
    implements EvaluatorContext, ParserContext, ResolveContext {
  final Map<String, int> multipleArgumentFunctionsLength;
  final Map<String, MultipleArgumentFunction> multipleArgumentFunctions;
  final Map<String, TwoArgumentFunction> twoArgumentFunctions;
  final Map<String, OneArgumentFunction> oneArgumentFunctions;
  final Map<String, TwoArgumentFunction> operators;
  final Map<String, CachedFunctionDeclaration> insertFunctions;
  final Map<String, double> variables;

  static const defaultOneArgumentFunctions = <String, OneArgumentFunction>{
    "tan": tan,
    "sin": sin,
    "cos": cos,
    "atan": atan,
    "asin": asin,
    "acos": acos,
    "sqrt": sqrt,
  };

  static const defaultTwoArgumentFunctions = <String, TwoArgumentFunction>{
    "root": root,
    "pow": pow,
    "log": log,
  };

  static const defaultOperators = <String, TwoArgumentFunction>{
    "+": sum,
    "-": minus,
    "*": multiply,
    "/": divide,
    "^": pow,
  };

  static const defaultConstants = <String, double>{
    "pi": pi,
    "e": e,
  };

  static final defaultIdentifiers = {
    ...defaultOneArgumentFunctions.keys,
    ...defaultTwoArgumentFunctions.keys,
    ...defaultOperators.keys,
    ...defaultConstants.keys,
  };

  // TODO: in constructor of CachedPlotFileParser,
  // TODO: be able to give custom functions, etc
  _ParsingContext()
      : multipleArgumentFunctions = {},
        multipleArgumentFunctionsLength = {},
        insertFunctions = {},
        twoArgumentFunctions = {...defaultTwoArgumentFunctions},
        oneArgumentFunctions = {...defaultOneArgumentFunctions},
        operators = {...defaultOperators},
        variables = {...defaultConstants};
  /* : assert(multipleArgumentFunctions.length ==
            multipleArgumentFunctionsLength.length)*/

  void addFunction(String name, CachedFunctionDeclaration function) {
    multipleArgumentFunctionsLength[name] = function.parameterLength;
    insertFunctions[name] = function;
    if (function.evaluatorFunction != null) {
      oneArgumentFunctions[name] = function.evaluatorFunction!;
    }
  }

  void addVariable(String name, CachedVariableDeclaration variable) {
    variables[name] = variable.value;
  }

  @override
  MultipleArgumentFunction getMultipleArgumentFunction(String name) {
    return multipleArgumentFunctions[name]!;
  }

  @override
  OneArgumentFunction getOneArgumentFunction(String name) {
    return oneArgumentFunctions[name]!;
  }

  @override
  TwoArgumentFunction getOperator(String name) {
    return operators[name]!;
  }

  @override
  TwoArgumentFunction getTwoArgumentFunction(String name) {
    return twoArgumentFunctions[name]!;
  }

  @override
  int? allowedFunctionParameterCount(String f) {
    if (oneArgumentFunctions.containsKey(f)) return 1;
    if (twoArgumentFunctions.containsKey(f)) return 2;
    return multipleArgumentFunctionsLength[f];
  }

  @override
  double? callFunction(String name, List<double> values) {
    return oneArgumentFunctions[name]?.call(values[0]) ??
        twoArgumentFunctions[name]?.call(values[0], values[1]) ??
        multipleArgumentFunctions[name]?.call(values);
  }

  @override
  double? callOperator(String operator, double operand1, double operand2) {
    return operators[operator]?.call(operand1, operand2);
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
      for (var i = 0; i < insertFunction.parameters.length; i++)
        insertFunction.parameters[i]: expressions[i]
    };
    return insertFunction.body.copyWithInsertVariables(variables);
  }

  @override
  bool variableAllowed(String v) {
    return variables[v] != null;
  }
}
