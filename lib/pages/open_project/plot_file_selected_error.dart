import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

import '../../blocs/selected_error/selected_error_cubit.dart';

class PlotFileSelectedError extends StatelessWidget {
  const PlotFileSelectedError({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedErrorCubit, SelectedErrorState>(
      builder: (context, state) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: state.errorIsSelected ? 1 : 0),
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Tooltip(
              message: state.selectedErrorMessage ?? "",
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: state.errorIsSelected
                        ? NordColors.$9
                        : Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.selectedErrorMessage ?? "",
                      style: const TextStyle(color: NordColors.$9),
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
