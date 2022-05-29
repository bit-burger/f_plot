import 'package:f_plot/pages/open_project/plot_file_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:math_code_field/math_code_field.dart';

import '../../blocs/selected_error/selected_error_cubit.dart';
import '../../theme/mathCodeFieldTheme.dart';
import '../../widgets/resizable_pane.dart';
import 'graphs_viewer.dart';

class OpenProjectContent extends StatelessWidget {
  const OpenProjectContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ResizablePane(
          minWidth: 250,
          startWidth: 250,
          maxWidth: 1000,
          resizableSide: ResizableSide.right,
          builder: (context, _) {
            return BlocProvider(
              create: (_) => SelectedErrorCubit()..noErrorSelected(),
              child: MathCodeFieldTheme(
                data: mathCodeFieldTheme,
                child: const PlotFileEditor(),
              ),
            );
          },
        ),
        const Expanded(child: GraphsViewer()),
      ],
    );
  }
}
