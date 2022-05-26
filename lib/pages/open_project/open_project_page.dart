import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:f_plot/pages/open_project/open_project_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenProjectPage extends StatelessWidget {
  const OpenProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final openProjectState = context.watch<OpenProjectCubit>().state;
    return Scaffold(
      appBar: const OpenProjectAppBar(),
      body: Center(
        child: Text(openProjectState.openProject.toString()),
      ),
    );
  }
}
