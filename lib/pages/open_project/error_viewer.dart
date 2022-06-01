import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorViewer extends StatelessWidget {
  const ErrorViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlotFileErrorsCubit>();
    final state = cubit.state;
    final errors = state.errors;
    return ListView.builder(
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return ListTile(
          title: Text(
            "${error.lineBegin}:${error.lineBeginFirstCharacter} ${error.message}",
          ),
          onTap: () {
            cubit .clickOnError(error);
          },
        );
      },
    );
  }
}
