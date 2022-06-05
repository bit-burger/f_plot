import 'package:f_plot/pages/open_project/error_viewer.dart';
import 'package:f_plot/pages/open_project/graph_functions_viewer.dart';
import 'package:f_plot/pages/open_project/plot_file_editor.dart';
import 'package:f_plot/pages/open_project/plot_file_selected_error.dart';
import 'package:f_plot/pages/open_project/variables_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:math_code_field/math_code_field.dart';

import '../../theme/math_code_field_theme.dart';
import '../../widgets/resizable_pane.dart';
import 'graphs_viewer.dart';

class OpenProjectContent extends StatelessWidget {
  const OpenProjectContent({super.key});

  // TODO: disable if PlotFileResultState.disabled is true
  Widget _buildPlotFileResult(BuildContext context) {
    return Column(
      children: [
        ResizablePane(
          min: 250,
          max: 1000,
          initialResizeValue: MediaQuery.of(context).size.height * (2 / 3),
          dividerColor: NordColors.$2,
          orientation: ResizableOrientation.vertical,
          dividerIsFromStart: false,
          dividerWidth: 6,
          child: const GraphsViewer(),
        ),
        Expanded(
          child: Row(
            children: [
              const Expanded(
                child: GraphFunctionsViewer(),
              ),
              ResizablePane(
                dividerWidth: 6,
                dividerColor: NordColors.$2,
                initialResizeValue: MediaQuery.of(context).size.width / 6,
                max: 1000,
                min: 250,
                dividerIsFromStart: true,
                child: const VariablesViewer(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlotFileEditing(BuildContext context) {
    return Column(
      children: [
        ResizablePane(
          min: 250,
          max: 1000,
          initialResizeValue: MediaQuery.of(context).size.height * (4 / 5),
          dividerColor: NordColors.$2,
          orientation: ResizableOrientation.vertical,
          dividerIsFromStart: false,
          dividerWidth: 6,
          child: Stack(
            children: [
              MathCodeFieldTheme(
                data: mathCodeFieldTheme,
                child: const PlotFileEditor(),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: PlotFileSelectedError(),
              ),
            ],
          ),
        ),
        const Expanded(
          child: ErrorViewer(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPlotFileEditing(context),
        ),
        ResizablePane(
          dividerWidth: 6,
          dividerColor: NordColors.$2,
          initialResizeValue: MediaQuery.of(context).size.width / 2,
          max: 1000,
          min: 500,
          child: _buildPlotFileResult(context),
        ),
      ],
    );
  }
}
