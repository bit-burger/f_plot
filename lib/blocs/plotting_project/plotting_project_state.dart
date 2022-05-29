part of 'plotting_project_cubit.dart';

@immutable
class Variable {
  final String name;
  final double value;

  const Variable({required this.name, required this.value});

  factory Variable.fromCachedVariableDeclaration({
    required String name,
    required CachedVariableDeclaration declaration,
  }) {
    return Variable(name: name, value: declaration.value);
  }
}

@immutable
class GraphFunction {
  final String name;
  final List<String> parameters;
  final Expression _expression;
  final double Function(double)? _callableFunction;
  final Color? _color;

  bool get isSingleVariableFunction => _callableFunction != null;

  Color get color {
    assert(isSingleVariableFunction);
    return _color!;
  }

  double Function(double) get function {
    assert(isSingleVariableFunction);
    return _callableFunction!;
  }

  GraphFunction.singleParameterFunction({
    required this.name,
    required String parameterName,
    required Expression expression,
    required double Function(double) callableFunction,
    required Color color,
  })  : parameters = [parameterName],
        _expression = expression,
        _callableFunction = callableFunction,
        _color = color;

  const GraphFunction.multipleParameterFunction({
    required this.name,
    required this.parameters,
    required Expression expression,
  })  : _callableFunction = null,
        _color = null,
        _expression = expression;

  factory GraphFunction.fromCachedFunctionDeclaration({
    required String name,
    required CachedFunctionDeclaration declaration,
    required Color color,
  }) {
    if (declaration.evaluatorFunction != null) {
      return GraphFunction.singleParameterFunction(
        name: name,
        parameterName: declaration.parameters[0],
        expression: declaration.body,
        callableFunction: declaration.evaluatorFunction!,
        color: color,
      );
    }
    return GraphFunction.multipleParameterFunction(
      name: name,
      parameters: declaration.parameters,
      expression: declaration.body,
    );
  }

  double callFunction(List<double> parameters) {
    if (isSingleVariableFunction) {
      return _callableFunction!.call(parameters[0]);
    }
    return _expression.resolveToNumber(
      ResolveContext.custom(
        variables: {
          for (var i = 0; i < parameters.length; i++)
            this.parameters[0]: parameters[0],
        },
      ),
    );
  }
}

@immutable
class PlottingProjectState {
  static const _graphColors = <Color>[
    NordColors.$11,
    NordColors.$12,
    NordColors.$13,
    NordColors.$14,
    NordColors.$15,
  ];

  final List<StringExpressionParseError> errors;
  final List<GraphFunction> functions;
  final List<Variable> variables;

  const PlottingProjectState({
    this.errors = const [],
    this.functions = const [],
    this.variables = const [],
  });

  factory PlottingProjectState.initial() {
    return const PlottingProjectState();
  }

  PlottingProjectState copyWith({
    List<StringExpressionParseError>? errors,
    List<GraphFunction>? functions,
    List<Variable>? variables,
  }) {
    return PlottingProjectState(
      errors: errors ?? this.errors,
      functions: functions ?? this.functions,
      variables: variables ?? this.variables,
    );
  }

  static Color colorFromFunctionNumber(int num) {
    var index = 0;
    var i = 0;
    while (i < num) {
      index++;
      if (index == _graphColors.length) {
        index = 0;
      }
      i++;
    }
    return _graphColors[index];
  }

  static List<GraphFunction> graphFunctionsFromCachedFunctionDeclarationMap(
    Map<String, CachedFunctionDeclaration> declarations,
  ) {
    final List<GraphFunction> ls = [];
    var functionNumber = 0;
    for (var i = 0; i < declarations.length; i++) {
      late final String declarationName;
      late final CachedFunctionDeclaration declaration;
      declarations.forEach((key, value) {
        if (value.order == i) {
          declarationName = key;
          declaration = value;
        }
      });
      ls.add(
        GraphFunction.fromCachedFunctionDeclaration(
          name: declarationName,
          declaration: declaration,
          color: colorFromFunctionNumber(functionNumber),
        ),
      );
      if (declaration.evaluatorFunction != null) {
        functionNumber++;
      }
    }
    return ls;
  }

  static List<Variable> variablesFromCachedVariableDeclarationMap(
    Map<String, CachedVariableDeclaration> declarations,
  ) {
    final List<Variable> ls = [];
    for (var i = 0; i < declarations.length; i++) {
      late final String declarationName;
      late final CachedVariableDeclaration declaration;
      declarations.forEach((key, value) {
        if (value.order == i) {
          declarationName = key;
          declaration = value;
        }
      });
      ls.add(
        Variable.fromCachedVariableDeclaration(
          name: declarationName,
          declaration: declaration,
        ),
      );
    }
    return ls;
  }

  static const DeepCollectionEquality _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) {
    if (other is PlottingProjectState) {
      return functions == other.functions &&
          variables == other.variables &&
          _equality.equals(other.errors, errors);
    }
    return false;
  }
}
