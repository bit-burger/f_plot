import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class PlotFileSelectedError extends StatelessWidget {
  const PlotFileSelectedError({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlotFileErrorsCubit, PlotFileErrorsState>(
      builder: (context, state) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: state.errorIsSelected ? 1 : 0),
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Tooltip(
              message: state.selectedError?.message ?? "",
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 13,
                    color: state.errorIsSelected
                        ? NordColors.$9
                        : Colors.transparent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      state.selectedError?.message ?? "",
                      style:
                          const TextStyle(color: NordColors.$9, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          builder: (context, animation, child) {
            if (animation == 0) {
              return const SizedBox();
            }
            return Transform.scale(
              alignment: Alignment.bottomCenter,
              scaleY: animation,
              child: ColoredBox(
                color: NordColors.$1,
                child: Opacity(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
