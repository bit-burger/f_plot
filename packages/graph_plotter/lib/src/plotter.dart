import 'dart:ui' as ui;

import 'controller.dart';
import 'type_defs.dart';
import 'painting.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// what should happen if a mouse,
/// that is in the area of the [GraphPlotter] scrolls
enum GraphPlotterScrollAction {
  /// zooms, only uses the vertical scroll aka the mouse wheel
  zoom,

  /// uses both the vertical scroll and the horizontal scroll to move around,
  /// only makes sense with a mouse that can scroll in both directions,
  /// such as the apple mouse
  move,

  /// does not do anything when scrolling
  none,
}

/// a view too zoom and move around plotted functiosn
class GraphPlotter extends StatefulWidget {
  /// the controller, which controls the [GraphPlotter],
  /// if none is given an internal one will be inserted
  final GraphPlotterController? controller;

  /// quality/resolution of the graphs displayed,
  /// if null is given, a responsive [GraphsPainterQuality]
  /// will be computed for the surrounding size of the [GraphPlotter]
  ///
  /// see [GraphsPainter.quality] for more information
  final GraphsPainterQuality? quality;

  /// if turned on, panning is disabled and
  /// holding and moving the mouse will do nothing
  final bool disablePanning;

  /// show [SystemMouseCursors.grab] and [SystemMouseCursors.grabbing]
  final bool showGrabCursorForMousePanning;

  /// what to do on a mouse scroll, see [GraphPlotterScrollAction]
  final GraphPlotterScrollAction scrollAction;

  /// if [scrollAction] is set to [GraphPlotterScrollAction.zoom],
  /// the scroll delta of the vertical scroll,
  /// aka the mouse wheel is multiplied with the [scrollDeltaToZoomRatio]
  /// and then applied to the current position and view area
  final double scrollDeltaToZoomRatio;

  /// which functions and their respective color to render
  final List<GraphAttributes> graphs;

  /// the stroke width of each graph
  final double graphsWidth;

  /// if the x-axis and y-axis should be shown or not
  final bool showAxis;

  /// the color of the axes
  final Color axisColor;

  /// the stroke width
  final double axisWidth;

  /// the text style of the axis labels,
  /// specified in the constructor as a [TextStyle] instead of [ui.TextStyle]
  final ui.TextStyle axisLabelsTextStyle;

  GraphPlotter({
    Key? key,
    this.controller,
    this.quality,
    this.disablePanning = false,
    this.showGrabCursorForMousePanning = true,
    this.scrollAction = GraphPlotterScrollAction.zoom,
    this.scrollDeltaToZoomRatio = 1 / 200,
    this.graphsWidth = 4,
    this.showAxis = true,
    this.axisColor = Colors.black,
    this.axisWidth = 2,
    TextStyle axisLabelsTextStyle = const TextStyle(color: Colors.black),
    required this.graphs,
  })  : axisLabelsTextStyle = axisLabelsTextStyle.getTextStyle(),
        super(key: key);

  @override
  State<GraphPlotter> createState() => _GraphPlotterState();
}

class _GraphPlotterState extends State<GraphPlotter> {
  late GraphPlotterController? _controller;
  GraphPlotterController get _effectiveController =>
      _controller ?? widget.controller!;

  var _isPanning = false;

  void _setIsPanning(bool isPanning) {
    setState(() {
      _isPanning = isPanning;
    });
  }

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = GraphPlotterController.fromZero(
        width: 1,
        height: 1,
      );
    } else {
      _controller = null;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GraphPlotter oldWidget) {
    if (widget.controller != null && _controller != null) {
      _controller = null;
    } else {
      _controller ??= widget.controller;
      _controller ??= GraphPlotterController.fromZero(
        width: 1,
        height: 1,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget w = LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final sizeWidth = size.width;
        late final GraphsPainterQuality quality;
        if (widget.quality != null) {
          quality = widget.quality!;
        } else {
          quality = _automaticQualityForRange(sizeWidth);
        }
        final sizeHeight = size.height;
        return Listener(
          onPointerSignal: (event) {
            // mouse scrolling
            if (widget.scrollAction == GraphPlotterScrollAction.none) {
              return;
            }
            if (event is PointerScrollEvent) {
              setState(() {
                final xSizeRatio = _effectiveController.xOffset / sizeWidth;
                final ySizeRatio = _effectiveController.yOffset / sizeHeight;
                if (widget.scrollAction == GraphPlotterScrollAction.move) {
                  // move with the mouse
                  final dx = event.scrollDelta.dx * xSizeRatio;
                  final dy = event.scrollDelta.dy * ySizeRatio;
                  _effectiveController.applyVector(dx, dy);
                  // _effectiveController.x += event.scrollDelta.dx * xSizeRatio;
                  // _effectiveController.y -= event.scrollDelta.dy * ySizeRatio;
                } else if (widget.scrollAction ==
                    GraphPlotterScrollAction.zoom) {
                  // zoom with the mouse
                  var zoomRatio =
                      1 + event.scrollDelta.dy * widget.scrollDeltaToZoomRatio;
                  zoomRatio = _effectiveController
                      .enforceZoomRatioBoundaries(zoomRatio);

                  if (zoomRatio > 1 &&
                      (_effectiveController.xOffset >
                              GraphPlotterController.maxX * 2 ||
                          _effectiveController.yOffset >
                              GraphPlotterController.maxY * 2)) {
                    return;
                  }

                  final zoomPoint = event.localPosition;
                  // x-coordinates
                  final currentLeftWidth = zoomPoint.dx;
                  final currentRightWidth = sizeWidth - currentLeftWidth;
                  final newLeftWidth = zoomRatio * currentLeftWidth;
                  final newRightWidth = zoomRatio * currentRightWidth;
                  final newX = currentLeftWidth - newLeftWidth;
                  final newXOffset = newLeftWidth + newRightWidth;
                  // translate coordinates of flutter to those of the controller
                  _effectiveController.x += newX * xSizeRatio;
                  _effectiveController.xOffset = newXOffset * xSizeRatio;
                  // y-coordinates
                  final currentLowerHeight = zoomPoint.dy;
                  final currentUpperHeight = sizeHeight - currentLowerHeight;
                  final newUpperHeight = zoomRatio * currentUpperHeight;
                  final newLowerHeight = zoomRatio * currentLowerHeight;
                  final newY = currentUpperHeight - newUpperHeight;
                  final newYOffset = newUpperHeight + newLowerHeight;
                  // translate coordinates of flutter to those of the controller
                  _effectiveController.y += newY * ySizeRatio;
                  _effectiveController.yOffset = newYOffset * ySizeRatio;
                }
                _effectiveController.update();
              });
            }
          },
          child: GestureDetector(
            // panning
            onPanStart: (_) {
              _setIsPanning(true);
            },
            onPanUpdate: widget.disablePanning
                ? null
                : (details) {
                    setState(() {
                      final xSizeRatio =
                          _effectiveController.xOffset / sizeWidth;
                      final ySizeRatio =
                          _effectiveController.yOffset / sizeHeight;
                      final dx = -details.delta.dx * xSizeRatio;
                      final dy = details.delta.dy * ySizeRatio;
                      _effectiveController.applyVector(dx, dy);
                    });
                  },
            onPanEnd: (_) {
              _setIsPanning(false);
            },
            onPanCancel: () {
              _setIsPanning(false);
            },
            // use AnimatedBuilder to re-render on each controller update
            child: AnimatedBuilder(
              animation: _effectiveController,
              builder: (_, __) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: GraphsPainter(
                    x: _effectiveController.x,
                    y: _effectiveController.y,
                    xOffset: _effectiveController.xOffset,
                    yOffset: _effectiveController.yOffset,
                    quality: quality,
                    labelTextStyle: widget.axisLabelsTextStyle,
                    axisColor: widget.axisColor,
                    axisWidth: widget.axisWidth,
                    graphsWidth: widget.graphsWidth,
                    showAxis: widget.showAxis,
                    graphs: widget.graphs,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    if (widget.showGrabCursorForMousePanning) {
      return MouseRegion(
        cursor: _isPanning == false
            ? SystemMouseCursors.grab
            : SystemMouseCursors.grabbing,
        child: w,
      );
    }
    return w;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// compute a optimal quality for a given range
  ///
  /// beware that this "optimal" quality is opinionated
  static GraphsPainterQuality _automaticQualityForRange(double range) {
    if (range > 3000) {
      return GraphsPainterQuality.lowest;
    } else if (range > 2500) {
      return GraphsPainterQuality.extremelyLow;
    } else if (range > 2000) {
      return GraphsPainterQuality.veryLow;
    } else if (range > 1000) {
      return GraphsPainterQuality.low;
    } else if (range > 250) {
      return GraphsPainterQuality.medium;
    } else {
      return GraphsPainterQuality.high;
    }
  }
}
