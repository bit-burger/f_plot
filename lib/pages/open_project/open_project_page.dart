import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/blocs/plotting_project/plotting_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'open_project_content.dart';

class OpenProjectPage extends StatefulWidget {
  const OpenProjectPage({super.key});

  @override
  State<OpenProjectPage> createState() => _OpenProjectPageState();
}

class _OpenProjectPageState extends State<OpenProjectPage> {
  late final PlottingProjectCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = PlottingProjectCubit()
      ..loadPlotfile(
          context.read<OpenProjectCubit>().state.openProject!.plotFile);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OpenProjectCubit, OpenProjectState>(
      listenWhen: (oldState, newState) => newState.projectIsOpen,
      listener: (context, state) {
        cubit.write(state.openProject!.plotFile);
      },
      child: Scaffold(
        appBar: const OpenProjectAppBar(),
        body: BlocProvider.value(
          value: cubit,
          child: Builder(builder: (context) {
            return const OpenProjectContent();
          }),
          // child: ,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    cubit.close();
  }
}
