import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectPage extends StatelessWidget {
  const OpenProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OpenProjectAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            BlocBuilder<OpenProjectCubit, OpenProjectState>(
              buildWhen: (_, newState) => newState.projectIsOpen,
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.openProject!.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.openProject!.plotFile,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              child: const Text("edit plot file"),
              onPressed: () {
                final cubit = context.read<OpenProjectCubit>();
                cubit.editPlotfile(cubit.state.openProject!.plotFile + "a");
              },
            ),
          ],
        ),
      ),
    );
  }
}
