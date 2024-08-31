import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plot_file/plot_file.dart';

import "../../theme/colors.dart";

part 'plot_file_result_state.dart';
part 'results.dart';

class PlotFileResultCubit extends Cubit<PlotFileResultState> {
  PlotFileResultCubit() : super(PlotFileResultState.initial());

  void updateErrorlessPlotFile(
    Map<String, CachedFunctionDeclaration> functionDeclarations,
    Map<String, CachedVariableDeclaration> variableDeclarations,
  ) {
    final removedFunctionNames =
        state.functions.map((function) => function.name).where(
              (functionName) => !functionDeclarations.containsKey(functionName),
            );
    emit(
      state.copyWith(
        disabled: false,
        cachedFunctionDeclarations: functionDeclarations,
        cachedVariableDeclarations: variableDeclarations,
        hiddenFunctionsNames: {...state.hiddenFunctionsNames}
          ..removeAll(removedFunctionNames),
      ),
    );
  }

  void plotFileContainsErrors() {
    emit(state.copyWith(disabled: true));
  }

  void hideFunction(String functionName) {
    emit(
      state.copyWith(
        hiddenFunctionsNames: {...state.hiddenFunctionsNames, functionName},
      ),
    );
  }

  void showFunction(String functionName) {
    emit(
      state.copyWith(
        hiddenFunctionsNames: {...state.hiddenFunctionsNames}
          ..remove(functionName),
      ),
    );
  }
}
