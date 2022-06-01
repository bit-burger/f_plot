import 'dart:async';

import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _plottingProjectCubit = PlottingProjectCubit()
      ..loadPlotfile(
          context.read<OpenProjectCubit>().state.openProject!.plotFile);
    _plottingProjectCubitSub = _plottingProjectCubit.stream.listen((state) {
      _plotFileErrorsCubit.updatePlotFile(state.errors, state.plotFile);
    });
    _plotFileErrorsCubit = PlotFileErrorsCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OpenProjectCubit, OpenProjectState>(
      listenWhen: (oldState, newState) => newState.projectIsOpen,
      listener: (context, state) {
        _plottingProjectCubit.write(state.openProject!.plotFile);
      },
      child: Scaffold(
        appBar: const OpenProjectAppBar(),
        body: BlocProvider.value(
          value: _plottingProjectCubit,
          child: BlocProvider.value(
            value: _plotFileErrorsCubit,
            child: Builder(
              builder: (context) {
                return const OpenProjectContent();
              },
            ),
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
