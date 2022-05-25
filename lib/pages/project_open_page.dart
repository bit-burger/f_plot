import 'package:f_plot/blocs/open_project/open_project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectOpenPage extends StatelessWidget {
  const ProjectOpenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final openProjectState = context.watch<OpenProjectCubit>().state;
    return Center(
      child: Text(openProjectState.openProject.toString()),
    );
  }
}
