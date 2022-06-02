import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

class ErrorViewer extends StatelessWidget {
  const ErrorViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlotFileErrorsCubit, PlotFileErrorsState>(
      builder: (context, state) {
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
                context.read<PlotFileErrorsCubit>().clickOnError(error);
              },
              selected: index == state.selectedErrorIndex,
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      },
    );
  }
}

//
// import 'package:f_plot/blocs/plot_file_errors/plot_file_errors_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_nord_theme/flutter_nord_theme.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//
// extension on ItemPosition {
//   bool get visible => itemLeadingEdge >= 0 && itemTrailingEdge <= 0;
// }
//
// class ErrorViewer extends StatefulWidget {
//   const ErrorViewer({super.key});
//
//   @override
//   State<ErrorViewer> createState() => _ErrorViewerState();
// }
//
// class _ErrorViewerState extends State<ErrorViewer> {
//   static const _scrollDuration = Duration(milliseconds: 350);
//
//   late final ItemScrollController _itemScrollController;
//   late final ItemPositionsListener _itemPositionsListener;
//
//   @override
//   void initState() {
//     super.initState();
//     _itemScrollController = ItemScrollController();
//     _itemPositionsListener = ItemPositionsListener.create();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PlotFileErrorsCubit, PlotFileErrorsState>(
//       listener: (context, state) {
//         if (state.errorIsSelected) {
//           final selectedIndex = state.selectedErrorIndex;
//           final selectedIsVisible = _itemPositionsListener.itemPositions.value
//               .toList(growable: false)[selectedIndex]
//               .visible;
//           if (!selectedIsVisible) {
//             _itemScrollController.jumpTo(
//               index: state.selectedErrorIndex,
//               // duration: _scrollDuration,
//             );
//           }
//         }
//       },
//       builder: (context, state) {
//         final errors = state.errors;
//         if (errors.isEmpty) {
//           return Center(
//             child: Text(
//               "no errors found",
//               style: Theme.of(context).textTheme.caption,
//             ),
//           );
//         }
//         return ScrollablePositionedList.separated(
//           itemPositionsListener: _itemPositionsListener,
//           itemScrollController: _itemScrollController,
//           itemCount: errors.length,
//           itemBuilder: (context, index) {
//             final error = errors[index];
//             return ListTile(
//               title: Text(
//                 "${error.lineBegin}:${error.lineBeginFirstCharacter} ${error.message}",
//                 style: const TextStyle(
//                   color: NordColors.$9,
//                 ),
//               ),
//               onTap: () {
//                 context.read<PlotFileErrorsCubit>().clickOnError(error);
//               },
//               selected: index == state.selectedErrorIndex,
//             );
//           },
//           separatorBuilder: (BuildContext context, int index) =>
//           const Divider(),
//         );
//       },
//     );
//   }
// }
