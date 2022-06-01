import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
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
  late final FocusNode _codeFocusNode;

  late final MathCodeEditingController _codeEditingController;
  late int _lastCursorPosition;

  @override
  void initState() {
    super.initState();

    _codeFocusNode = FocusNode();

    final initialPlotFile =
        context.read<OpenProjectCubit>().state.openProject!.plotFile;

    _codeEditingController = MathCodeEditingController();
    _codeEditingController.text = initialPlotFile;
    _lastCursorPosition = _codeEditingController.selection.start;

    _codeEditingController.addListener(_onSelectionChange);
  }

  void _onSelectionChange() {
    final newCursorPosition = _codeEditingController.selection.start;
    if (newCursorPosition != _lastCursorPosition) {
      context
          .read<PlotFileErrorsCubit>()
          .changeCursorPosition(newCursorPosition);
      _lastCursorPosition = newCursorPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final openProjectCubit = context.read<OpenProjectCubit>();
    final plottingProjectState = context.watch<PlotFileErrorsCubit>().state;
    return BlocListener<PlotFileErrorsCubit, PlotFileErrorsState>(
      listener: (context, state) {
        if (state.lastSelectedErrorCursorPosition != null) {
          _codeFocusNode.requestFocus();
          _codeEditingController.selection = TextSelection(
            baseOffset: state.lastSelectedErrorCursorPosition!,
            extentOffset: state.lastSelectedErrorCursorPosition!,
          );
        }
      },
      child: MathCodeField(
        focusNode: _codeFocusNode,
        codeEditingController: _codeEditingController,
        monoTextTheme: GoogleFonts.jetBrainsMonoTextTheme(),
        codeErrors: plottingProjectState.errors,
        textChanged: (plotFile) {
          openProjectCubit.editPlotfile(plotFile);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _codeEditingController.removeListener(_onSelectionChange);
  }
}
