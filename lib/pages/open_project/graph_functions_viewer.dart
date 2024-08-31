import 'package:flutter_plotter/blocs/plot_file_result/plot_file_result_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import "../../theme/colors.dart";

class GraphFunctionsViewer extends StatelessWidget {
  const GraphFunctionsViewer({super.key});

  Widget _buildFunction(GraphFunction function, {required bool hasColor}) {
    return AnimatedDefaultTextStyle(
      key: ValueKey(function.name),
      style: GoogleFonts.jetBrainsMono().copyWith(
        fontSize: 16,
        color: hasColor ? function.color : NordColors.$3,
      ),
      duration: const Duration(milliseconds: 500),
      child: Text(
        "${function.name}(${function.parameters.join(",")}) = "
        "${function.expression.toString()}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PlotFileResultCubit>();
    final state = cubit.state;
    if (state.cachedFunctionDeclarations.isEmpty) {
      return Center(
        child: Text(
          "no functions",
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: NordColors.$3),
        ),
      );
    }
    return ListView.separated(
      controller: ScrollController(),
      itemCount: state.functions.length,
      itemBuilder: (context, index) {
        final graphFunction = state.functions[index];
        if (!graphFunction.isSingleVariableFunction) {
          return ListTile(
            title: _buildFunction(graphFunction, hasColor: false),
          );
        }
        final isChecked =
            !state.hiddenFunctionsNames.contains(graphFunction.name);
        return CheckboxListTile(
          title: _buildFunction(graphFunction, hasColor: isChecked),
          value: isChecked,
          onChanged: (newCheckedValue) {
            if (newCheckedValue == true) {
              cubit.showFunction(graphFunction.name);
            } else {
              cubit.hideFunction(graphFunction.name);
            }
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
