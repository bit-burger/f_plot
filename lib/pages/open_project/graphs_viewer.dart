import 'package:f_plot/blocs/plotting_project/plotting_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:graph_plotter/graph_plotter.dart';

class GraphsViewer extends StatelessWidget {
  const GraphsViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlottingProjectCubit, PlottingProjectState>(
      buildWhen: (oldState, newState) =>
          oldState.functions != newState.functions,
      builder: (context, state) {
        return ClipRect(
          child: GraphPlotter(
            axisWidth: 2.5,
            axisColor: NordColors.$3,
            graphsWidth: 3,
            axisLabelsTextStyle: const TextStyle(color: NordColors.$3, fontWeight: FontWeight.w500),
            graphs: state.functions
                .where((function) => function.isSingleVariableFunction)
                .map(
                  (function) => GraphAttributes(
                      evaluatingFunction: function.function,
                      color: function.color,
                      name: function.name),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }
}
