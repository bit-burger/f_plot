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

    return ListView.separated(
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
