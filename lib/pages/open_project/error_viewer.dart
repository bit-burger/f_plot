import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class ErrorViewer extends StatelessWidget {
  const ErrorViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PlotFileErrorsCubit>();
    final state = cubit.state;
    final errors = state.errors;
    if (errors.isEmpty) {
      return Center(
        child: Text(
          "no errors found",
          style: Theme.of(context).textTheme.caption,
        ),
      );
    }
    return ListView.separated(
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return ListTile(
          title: Text(
            "${error.lineBegin}:${error.lineBeginFirstCharacter} ${error.message}",
            style: const TextStyle(
              color: NordColors.$9,
            ),
          ),
          onTap: () {
            cubit.clickOnError(error);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
