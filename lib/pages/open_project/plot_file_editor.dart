import 'package:f_plot/blocs/plotting_project/plotting_project_cubit.dart';
import 'package:f_plot/blocs/selected_error/selected_error_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_code_field/math_code_field.dart';

import '../../blocs/open_project/open_project_cubit.dart';

class PlotFileEditor extends StatefulWidget {
  const PlotFileEditor({super.key});

  @override
  State<PlotFileEditor> createState() => _PlotFileEditorState();
}

class _PlotFileEditorState extends State<PlotFileEditor> {
  late final MathCodeEditingController _codeEditingController;

  @override
  void initState() {
    super.initState();

    final initialPlotFile =
        context.read<OpenProjectCubit>().state.openProject!.plotFile;

    _codeEditingController = MathCodeEditingController();
    _codeEditingController.text = initialPlotFile;
  }

  @override
  Widget build(BuildContext context) {
    final openProjectCubit = context.read<OpenProjectCubit>();
    final plottingProjectState = context.watch<PlottingProjectCubit>().state;
    return MathCodeField(
      codeEditingController: _codeEditingController,
      monoTextTheme: GoogleFonts.jetBrainsMonoTextTheme(),
      codeErrors: plottingProjectState.errors
          .map((error) => CodeError(
              begin: error.from, end: error.to, message: error.message))
          .toList(growable: false),
      textChanged: (plotFile) {
        openProjectCubit.editPlotfile(plotFile);
      },
      errorSelectionExact: false,
      errorSelectionChanged: (codeError) {
        context.read<SelectedErrorCubit>().select(codeError?.message);
      },
    );
  }
}
