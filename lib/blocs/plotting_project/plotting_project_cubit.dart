import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:expressions/expressions.dart';
import 'package:f_plot/repositories/projects/projects_repository_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:meta/meta.dart';
import 'package:plot_file/plot_file.dart';

part 'plotting_project_state.dart';

class PlottingProjectCubit extends Cubit<PlottingProjectState> {
  final CachedPlotFileParser cachedPlotFileParser = CachedPlotFileParser();

  PlottingProjectCubit() : super(PlottingProjectState.initial());

  void loadPlotfile(String plotFile) {
    cachedPlotFileParser.parseAndCache(plotFile);
    if (cachedPlotFileParser.errors.isNotEmpty) {
      emit(PlottingProjectState(errors: [...cachedPlotFileParser.errors]));
    } else {
      emit(
        PlottingProjectState(
          variables:
              PlottingProjectState.variablesFromCachedVariableDeclarationMap(
            cachedPlotFileParser.variables,
          ),
          functions: PlottingProjectState
              .graphFunctionsFromCachedFunctionDeclarationMap(
            cachedPlotFileParser.functions,
          ),
        ),
      );
    }
  }

  void write(String plotFile) {
    cachedPlotFileParser.parseAndCache(plotFile);
    if (cachedPlotFileParser.errors.isNotEmpty) {
      emit(state.copyWith(errors: [...cachedPlotFileParser.errors]));
    } else {
      emit(
        PlottingProjectState(
          variables:
              PlottingProjectState.variablesFromCachedVariableDeclarationMap(
            cachedPlotFileParser.variables,
          ),
          functions: PlottingProjectState
              .graphFunctionsFromCachedFunctionDeclarationMap(
            cachedPlotFileParser.functions,
          ),
        ),
      );
    }
  }

  void changeWindowConfig() {
    // TODO: implement changeWindowConfig
    throw UnimplementedError();
  }
}
