import 'dart:async';

import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
import 'package:f_plot/blocs/plot_file_result/plot_file_result_cubit.dart';
import 'package:f_plot/blocs/plotting_project/plotting_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'open_project_content.dart';

class OpenProjectPage extends StatefulWidget {
  const OpenProjectPage({super.key});

  @override
  State<OpenProjectPage> createState() => _OpenProjectPageState();
}

class _OpenProjectPageState extends State<OpenProjectPage> {
  late final PlottingProjectCubit _plottingProjectCubit;
  late final StreamSubscription<PlottingProjectState> _plottingProjectCubitSub;
  late final PlotFileErrorsCubit _plotFileErrorsCubit;
  late final PlotFileResultCubit _plotFileResultCubit;

  @override
  void initState() {
    super.initState();
    _plotFileErrorsCubit = PlotFileErrorsCubit()..unfocusPlotFileEditor();
    _plottingProjectCubit = PlottingProjectCubit();
    _plotFileResultCubit = PlotFileResultCubit();

    _plottingProjectCubitSub =
        _plottingProjectCubit.stream.listen(_plotFileUpdate);

    _plottingProjectCubit.loadPlotfile(
        context.read<OpenProjectCubit>().state.openProject!.plotFile);
  }

  void _plotFileUpdate(PlottingProjectState state) {
    _plotFileErrorsCubit.updatePlotFile(state.errors, state.plotFile);
    if (state.errors.isNotEmpty) {
      _plotFileResultCubit.plotFileContainsErrors();
    } else {
      _plotFileResultCubit.updateErrorlessPlotFile(
        state.functions,
        state.variables,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: add listener for save keyboard shortcut
    return BlocListener<OpenProjectCubit, OpenProjectState>(
      listenWhen: (oldState, newState) => newState.projectIsOpen,
      listener: (context, state) {
        _plottingProjectCubit.write(state.openProject!.plotFile);
      },
      child: Scaffold(
        appBar: const OpenProjectAppBar(),
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _plotFileResultCubit),
            BlocProvider.value(value: _plotFileErrorsCubit),
            BlocProvider.value(value: _plottingProjectCubit),
          ],
          child: Builder(
            builder: (context) {
              return const OpenProjectContent();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _plottingProjectCubitSub.cancel();
    _plottingProjectCubit.close();
    _plotFileErrorsCubit.close();
  }
}
