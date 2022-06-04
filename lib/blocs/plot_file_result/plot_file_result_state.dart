part of 'plot_file_result_cubit.dart';

class PlotFileResultState extends Equatable {
  final bool disabled;
  final List<Variable> variables;
  final List<GraphFunction> functions;
  final Set<String> hiddenFunctionsNames;

  late final List<GraphFunction> shownFunctions = functions
      .where((function) =>
          function.isSingleVariableFunction &&
          !hiddenFunctionsNames.contains(function.name))
      .toList(growable: false);

  PlotFileResultState({
    this.disabled = false,
    this.variables = const [],
    this.functions = const [],
    this.hiddenFunctionsNames = const {},
  });

  factory PlotFileResultState.initial() = PlotFileResultState;

  @override
  List<Object?> get props => [
        disabled,
        variables,
        functions,
        hiddenFunctionsNames,
      ];

  PlotFileResultState copyWith({
    bool? disabled,
    List<Variable>? variables,
    List<GraphFunction>? functions,
    Set<String>? hiddenFunctionsNames,
  }) {
    return PlotFileResultState(
      disabled: disabled ?? this.disabled,
      variables: variables ?? this.variables,
      functions: functions ?? this.functions,
      hiddenFunctionsNames: hiddenFunctionsNames ?? this.hiddenFunctionsNames,
    );
  }
}
