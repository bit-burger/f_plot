import 'dart:math';

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

  static const maxX = 1e9;
  static const maxY = 1e9;
  static const minX = -maxX;
  static const minY = -maxY;
  static const maxWidth = 1e8;
  static const maxHeight = 1e8;
  static const minOffset = 0.1;

  /// [xOffset] and [yOffset] should be greater than [minOffset]
  GraphPlotterController({
    required this.x,
    required this.y,
    required this.xOffset,
    required this.yOffset,
  })  : assert(xOffset > minOffset),
        assert(yOffset > minOffset);

  /// [width] and [height] should both be greater than [minXOffset] and [minYOffset]
  factory GraphPlotterController.fromZero({
    required double width,
    required double height,
  }) {
    return GraphPlotterController(x: 0, y: 0, xOffset: width, yOffset: height);
  }

  /// give smallest zoom ratio possible considering [minOffset]
  /// and keeping the same ratio between [xOffset] and [yOffset]
  double enforceZoomRatioBoundaries(double ratio) {
    if (ratio < 1) {
      return minZoomRatio(ratio);
    } else {
      return maxZoomRatio(ratio);
    }
  }

  /// used by [enforceZoomRatioBoundaries] for a ratio < 1
  double minZoomRatio(double ratio) {
    if (xOffset < yOffset) {
      if (xOffset * ratio < minOffset) {
        return minOffset / xOffset;
      }
    } else {
      if (yOffset * ratio < minOffset) {
        return minOffset / yOffset;
      }
    }
    return ratio;
  }

  /// used by [enforceZoomRatioBoundaries] for a ratio > 1
  double maxZoomRatio(double ratio) {
    // final newXOffsetDiff = (ratio * xOffset - xOffset);
    // final minusXExcess = minX - (x - (1 / 2) * newXOffsetDiff);
    // final xExcess = -maxX + (x + xOffset + (1 / 2) * newXOffsetDiff);
    // final maxXExcess = max(minusXExcess, xExcess);
    //
    // final newYOffsetDiff = (ratio * yOffset - yOffset);
    // final minusYExcess = minY - (y - (1 / 2) * newYOffsetDiff);
    // final yExcess = -maxY + (y + yOffset + (1 / 2) * newYOffsetDiff);
    // final maxYExcess = max(minusYExcess, yExcess);

    // if (maxXExcess > 0 || maxYExcess > 0) {
    //   if (maxXExcess > maxYExcess) {
    //     ratio *= maxXExcess / xOffset;
    //   } else {
    //     ratio -= maxYExcess / yOffset;
    //   }
    // }
    if (xOffset > yOffset) {
      if (xOffset * ratio > maxWidth) {
        return maxWidth / xOffset;
      }
    } else {
      if (yOffset * ratio > maxHeight) {
        return maxHeight / yOffset;
      }
    }
    return ratio;
  }

  /// zoom into the center of the controller with the specified [zoomRatio]
  void applyZoomRatioToCenter(double zoomRatio) {
    assert(zoomRatio > 0);

    zoomRatio = enforceZoomRatioBoundaries(zoomRatio);

    final middleX = x + xOffset / 2;
    final middleY = y + yOffset / 2;
    xOffset = xOffset * zoomRatio;
    yOffset = yOffset * zoomRatio;
    x = middleX - xOffset / 2;
    y = middleY - yOffset / 2;

    notifyListeners();
  }

  /// zoom into [xOffset]|[yOffset],
  /// beware that [xOffset] and [yOffset] are relative from [x]|[y]
  /// and should be smaller or equals to [xOffset] and [yOffset],
  /// as well as greater than 0
  /// as the point should lie in the rect outlined by
  /// [x], [y], [xOffset] and [yOffset]
  // void applyZoom(
  //   double xOffset,
  //   double yOffset,
  //   double zoomRatio,
  // ) {
  //   assert(xOffset > 0 && xOffset <= _xOffset);
  //   assert(yOffset > 0 && yOffset <= _yOffset);
  //   notifyListeners();
  // }

  void applyVector(double dx, double dy) {
    if (xOffset < maxX * 2) {
      if (dx > 0) {
        x = min(x + xOffset + dx, maxX) - xOffset;
      } else {
        x = max(x + dx, minX);
      }
    }
    if (yOffset < maxY * 2) {
      if (dy > 0) {
        y = min(y + yOffset + dy, maxY) - yOffset;
      } else {
        y = max(y + dy, minY);
      }
    }
    notifyListeners();
  }

  /// update the rect of the [GraphPlotterController] by x and y coordinates,
  /// as well as their offsets
  ///
  /// boundaries will be enforced
  // void updateRectRelative(double x, double xOffset, double y, double yOffset) {
  //   assert(xOffset > 0);
  //   assert(yOffset > 0);
  //   updateRect(x, x + xOffset, y, y + yOffset);
  // }

  /// update the rect of the [GraphPlotterController],
  /// by two x and y coordinates where [x1] < [x2] and [y1] < [y2]
  ///
  ///
  /// boundaries will be enforced
  // void updateRect(double x1, double x2, double y1, double y2) {
  //   assert(x1 < x2);
  //   assert(y1 < y2);
  //   notifyListeners();
  // }

  void update() {
    notifyListeners();
  }
}
