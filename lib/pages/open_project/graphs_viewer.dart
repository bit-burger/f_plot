import 'package:flutter_plotter/blocs/plot_file_result/plot_file_result_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graph_plotter/graph_plotter.dart';

import "../../theme/colors.dart";

class GraphsViewer extends StatefulWidget {
  const GraphsViewer({super.key});

  @override
  State<GraphsViewer> createState() => _GraphsViewerState();
}

class _GraphsViewerState extends State<GraphsViewer> {
  late final GraphPlotterController _graphPlotterController;

  @override
  void initState() {
    super.initState();
    _graphPlotterController =
        GraphPlotterController.fromZero(width: 20, height: 20)
          ..x = -10
          ..y = -10
          ..update();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlotFileResultCubit, PlotFileResultState>(
      builder: (context, state) {
        return ClipRect(
          child: GraphPlotter(
            controller: _graphPlotterController,
            axisWidth: 2.5,
            axisColor: NordColors.$3,
            graphsWidth: 3,
            axisLabelsTextStyle: const TextStyle(
                color: NordColors.$3, fontWeight: FontWeight.w500),
            graphs: state.shownFunctions
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

  @override
  void dispose() {
    super.dispose();
    _graphPlotterController.dispose();
  }
}
