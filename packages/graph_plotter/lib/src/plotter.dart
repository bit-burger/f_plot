import 'dart:ui' as ui;

import './controller.dart';
import './type_defs.dart';
import './painting.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum GraphPlotterScrollAction {
  zoom,
  move,
  none;
}

class GraphPlotter extends StatefulWidget {
  final GraphPlotterController? controller;

  final bool disablePanning;
  final bool showGrabCursorForMousePanning;
  final GraphPlotterScrollAction scrollAction;
  final double scrollDeltaToZoomRatio;

  final List<GraphAttributes> functions;
  final double graphsWidth;

  final bool showAxis;
  final Color axisColor;
  final double axisWidth;
  final ui.TextStyle axisLabelsTextStyle;

  GraphPlotter({
    Key? key,
    this.controller,
    this.disablePanning = false,
    this.showGrabCursorForMousePanning = true,
    this.scrollAction = GraphPlotterScrollAction.zoom,
    this.scrollDeltaToZoomRatio = 1 / 200,
    this.graphsWidth = 4,
    this.showAxis = true,
    this.axisColor = Colors.black,
    this.axisWidth = 2,
    TextStyle axisLabelsTextStyle = const TextStyle(color: Colors.black),
    required this.functions,
  })  : axisLabelsTextStyle = axisLabelsTextStyle.getTextStyle(),
        super(key: key);

  @override
  State<GraphPlotter> createState() =>
      _GraphPlotterState();
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
        final sizeHeight = size.height;
        return Listener(
          onPointerSignal: (event) {
            if (widget.scrollAction ==
                GraphPlotterScrollAction.none) {
              return;
            }
            if (event is PointerScrollEvent) {
              setState(() {
                final xSizeRatio = _effectiveController.xOffset / sizeWidth;
                final ySizeRatio = _effectiveController.yOffset / sizeHeight;
                if (widget.scrollAction ==
                    GraphPlotterScrollAction.move) {
                  _effectiveController.x += event.scrollDelta.dx * xSizeRatio;
                  _effectiveController.y -= event.scrollDelta.dy * ySizeRatio;
                } else if (widget.scrollAction ==
                    GraphPlotterScrollAction.zoom) {
                  final zoomRatio =
                      1 + event.scrollDelta.dy * widget.scrollDeltaToZoomRatio;
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
                      _effectiveController.x -= details.delta.dx * xSizeRatio;
                      _effectiveController.y += details.delta.dy * ySizeRatio;
                      _effectiveController.update();
                    });
                  },
            onPanEnd: (_) {
              _setIsPanning(false);
            },
            onPanCancel: () {
              _setIsPanning(false);
            },
            child: AnimatedBuilder(
              animation: _effectiveController,
              builder: (_, __) {
                return CustomPaint(
                  painter: GraphsPainter(
                    labelTextStyle: widget.axisLabelsTextStyle,
                    axisColor: widget.axisColor,
                    axisWidth: widget.axisWidth,
                    graphsWidth: widget.graphsWidth,
                    showAxis: widget.showAxis,
                    x: _effectiveController.x,
                    y: _effectiveController.y,
                    xOffset: _effectiveController.xOffset,
                    yOffset: _effectiveController.yOffset,
                    functions: widget.functions,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    if (widget.showGrabCursorForMousePanning) {
      return SizedBox.expand(
        child: MouseRegion(
          cursor: _isPanning == false
              ? SystemMouseCursors.grab
              : SystemMouseCursors.grabbing,
          child: w,
        ),
      );
    }
    return SizedBox.expand(child: w);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
