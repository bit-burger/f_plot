part of 'plot_file_result_cubit.dart';

class PlotFileResultState extends Equatable {
  final bool disabled;
  final Map<String, CachedVariableDeclaration> cachedVariableDeclarations;
  final Map<String, CachedFunctionDeclaration> cachedFunctionDeclarations;
  final Set<String> hiddenFunctionsNames;

  late final List<Variable> variables =
      Variable.variablesFromCachedVariableDeclarationMap(
    cachedVariableDeclarations,
  );
  late final List<GraphFunction> functions =
      GraphFunction.graphFunctionsFromCachedFunctionDeclarationMap(
    cachedFunctionDeclarations,
    hiddenFunctionsNames,
  );

  late final List<GraphFunction> shownFunctions = functions
      .where((function) =>
          function.isSingleVariableFunction &&
          !hiddenFunctionsNames.contains(function.name))
      .toList(growable: false);

  PlotFileResultState({
    this.disabled = false,
    this.cachedVariableDeclarations = const {},
    this.cachedFunctionDeclarations = const {},
    this.hiddenFunctionsNames = const {},
  });

  factory PlotFileResultState.initial() = PlotFileResultState;

  @override
  List<Object?> get props => [
        disabled,
        cachedFunctionDeclarations,
        cachedVariableDeclarations,
        hiddenFunctionsNames,
      ];

  PlotFileResultState copyWith({
    bool? disabled,
    Map<String, CachedVariableDeclaration>? cachedVariableDeclarations,
    Map<String, CachedFunctionDeclaration>? cachedFunctionDeclarations,
    Set<String>? hiddenFunctionsNames,
  }) {
    return PlotFileResultState(
      disabled: disabled ?? this.disabled,
      cachedVariableDeclarations:
          cachedVariableDeclarations ?? this.cachedVariableDeclarations,
      cachedFunctionDeclarations:
          cachedFunctionDeclarations ?? this.cachedFunctionDeclarations,
      hiddenFunctionsNames: hiddenFunctionsNames ?? this.hiddenFunctionsNames,
    );
  }
}
