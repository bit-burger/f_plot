part of 'plotting_project_cubit.dart';

@immutable
class PlottingProjectState {
  final List<StringExpressionParseError> errors;
  final Map<String, CachedFunctionDeclaration> functions;
  final Map<String, CachedVariableDeclaration> variables;
  final String plotFile;

  const PlottingProjectState({
    this.errors = const [],
    this.functions = const {},
    this.variables = const {},
    this.plotFile = "",
  });

  factory PlottingProjectState.initial() {
    return const PlottingProjectState();
  }

  PlottingProjectState copyWith({
    List<StringExpressionParseError>? errors,
    Map<String, CachedFunctionDeclaration>? functions,
    Map<String, CachedVariableDeclaration>? variables,
    String? plotFile,
  }) {
    return PlottingProjectState(
      errors: errors ?? this.errors,
      functions: functions ?? this.functions,
      variables: variables ?? this.variables,
      plotFile: plotFile ?? this.plotFile,
    );
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
