import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:plot_file/plot_file.dart';

part 'plotting_project_state.dart';

class PlottingProjectCubit extends Cubit<PlottingProjectState> {
  final CachedPlotFileParser cachedPlotFileParser = CachedPlotFileParser();

  PlottingProjectCubit() : super(PlottingProjectState.initial());

  void loadPlotfile(String plotFile) {
    cachedPlotFileParser.parseAndCache(plotFile);
    _emitPlotFileParserResults(
      plotFile: plotFile,
      copyFromOld: false,
    );
  }

  void write(String plotFile) {
    cachedPlotFileParser.parseAndCache(plotFile);
    _emitPlotFileParserResults(
      plotFile: plotFile,
      copyFromOld: true,
    );
  }

  void _emitPlotFileParserResults({
    required String plotFile,
    required bool copyFromOld,
  }) {
    if (cachedPlotFileParser.errors.isNotEmpty) {
      if (copyFromOld) {
        emit(
          state.copyWith(
            errors: [...cachedPlotFileParser.errors],
            plotFile: plotFile,
          ),
        );
      } else {
        emit(
          PlottingProjectState(
            errors: [...cachedPlotFileParser.errors],
            plotFile: plotFile,
          ),
        );
      }
    } else {
      emit(
        PlottingProjectState(
          variables: {
            for (final name in cachedPlotFileParser.variables.keys)
              name: cachedPlotFileParser.variables[name]!.copy(),
          },
          functions: {
            for (final name in cachedPlotFileParser.functions.keys)
              name: cachedPlotFileParser.functions[name]!.copy(),
          },
          plotFile: plotFile,
        ),
      );
    }
  }

  void changeWindowConfig() {
    // TODO: implement changeWindowConfig
    throw UnimplementedError();
  }
}
