import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/plot_file_result/plot_file_result_cubit.dart';

class VariablesViewer extends StatelessWidget {
  const VariablesViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PlotFileResultCubit>();
    final state = cubit.state;
    if (state.cachedFunctionDeclarations.isEmpty) {
      return Center(
        child: Text(
          "no variables",
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: NordColors.$3),
        ),
      );
    }
    return ListView.separated(
      controller: ScrollController(),
      itemCount: state.variables.length,
      itemBuilder: (context, index) {
        final variable = state.variables[index];
        return ListTile(
          title: Text(
            "${variable.name} = ${variable.value}",
            style: const TextStyle(
              color: NordColors.$3,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
