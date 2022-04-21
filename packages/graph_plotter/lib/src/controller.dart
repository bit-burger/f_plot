import 'package:flutter/foundation.dart';
import 'plotter.dart';

/// a controller for the [GraphPlotter],
/// used to control the [GraphPlotter]s view area,
/// see [GraphPlotter.controller] for more information.
///
/// always update the view area by calling [update]
///
/// example:
///
/// ```dart
/// final GraphPlotterController controller;
///
/// // some operations on the controller
/// controller.x = _x;
/// controller.y = _y;
/// ...
///
/// // update the GraphPlotters view area
/// controller.update();
/// ```
// TODO: maybe replace with extending a ValueNotifier<ui.Rect>
class GraphPlotterController extends ChangeNotifier {
  double x;
  double y;
  double xOffset;
  double yOffset;

  GraphPlotterController({
    required this.x,
    required this.y,
    required this.xOffset,
    required this.yOffset,
  });

  factory GraphPlotterController.fromZero({
    required double width,
    required double height,
  }) {
    return GraphPlotterController(x: 0, y: 0, xOffset: width, yOffset: height);
  }

  void update() {
    notifyListeners();
  }

  void applyZoomRatioToCenter(double zoomRatio) {
    assert(zoomRatio > 0);

    final middleX = x + xOffset / 2;
    final middleY = y + yOffset / 2;
    xOffset = xOffset * zoomRatio;
    yOffset = yOffset * zoomRatio;
    x = middleX - xOffset / 2;
    y = middleY - yOffset / 2;
  }
}
