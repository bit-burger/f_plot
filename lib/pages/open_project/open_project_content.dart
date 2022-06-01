import 'package:f_plot/pages/open_project/error_viewer.dart';
import 'package:f_plot/pages/open_project/plot_file_editor.dart';
import 'package:f_plot/pages/open_project/plot_file_selected_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:math_code_field/math_code_field.dart';

import '../../theme/math_code_field_theme.dart';
import '../../widgets/resizable_pane.dart';
import 'graphs_viewer.dart';

class OpenProjectContent extends StatelessWidget {
  const OpenProjectContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              ResizablePane(
                min: 250,
                max: 1000,
                initialResizeValue: 150,
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
          ),
        ),
        const ResizablePane(
          dividerWidth: 6,
          dividerColor: NordColors.$2,
          initialResizeValue: 500,
          max: 1000,
          min: 500,
          child: GraphsViewer(),
        ),
      ],
    );
  }
}
