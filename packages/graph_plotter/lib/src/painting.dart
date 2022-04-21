import 'dart:math' as math;
import 'dart:ui' as ui;

import './type_defs.dart';

import 'package:flutter/material.dart';

class GraphsPainter extends CustomPainter {
  final double x, y;
  final double xOffset, yOffset;
  // make sure functions is rebuilt if changes
  final List<GraphAttributes> functions;
  final double graphsWidth;

  final bool showAxis;
  final Color axisColor;
  final double axisWidth;
  final ui.TextStyle labelTextStyle;

  GraphsPainter({
    this.x = 0,
    this.y = 0,
    this.xOffset = 1,
    this.yOffset = 1,
    required this.functions,
    this.graphsWidth = 4,
    this.showAxis = true,
    this.axisColor = Colors.black,
    this.axisWidth = 2,
    required this.labelTextStyle,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (showAxis) {
      paintAxis(canvas, size);
    }
    paintGraph(canvas, size);
  }

  void paintAxis(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()
      ..color = axisColor
      ..strokeWidth = axisWidth;
    // y-axis
    final stepSizeX = xOffset / size.width;
    final xOfZeroY = -this.x / stepSizeX;
    final stepSizeY = yOffset / size.height;
    final yOfZeroX = size.height - (-this.y / stepSizeY);
    if (x <= 0 && 0 <= x + xOffset) {
      canvas.drawLine(
        ui.Offset(xOfZeroY, 0),
        ui.Offset(xOfZeroY, size.height),
        paint,
      );
      final yAxisStepSize = computeAxisStepSize(yOffset);
      final yStepOfYAxis = yAxisStepSize / stepSizeY;
      var currentYAxisStep = yAxisStepSize;
      for (var y = yOfZeroX - yStepOfYAxis; y >= 0; y -= yStepOfYAxis) {
        _paintAxisMarking(canvas, paint, labelTextStyle,
            currentYAxisStep.toString(), xOfZeroY, y, true);
        currentYAxisStep += yAxisStepSize;
      }
      currentYAxisStep = -yAxisStepSize;
      for (var y = yOfZeroX + yStepOfYAxis;
          y <= size.height;
          y += yStepOfYAxis) {
        _paintAxisMarking(canvas, paint, labelTextStyle,
            currentYAxisStep.toString(), xOfZeroY, y, true);
        currentYAxisStep -= yAxisStepSize;
      }
    }
    // x-axis
    if (y <= 0 && 0 <= y + yOffset) {
      canvas.drawLine(
        ui.Offset(0, yOfZeroX),
        ui.Offset(size.width, yOfZeroX),
        paint,
      );
      final xAxisStepSize = computeAxisStepSize(xOffset);
      final xStepOfXAxis = xAxisStepSize / stepSizeX;
      var currentXAxisStep = xAxisStepSize;
      for (var x = xOfZeroY + xStepOfXAxis;
          x <= size.width;
          x += xStepOfXAxis) {
        _paintAxisMarking(canvas, paint, labelTextStyle,
            currentXAxisStep.toString(), x, yOfZeroX, false);
        currentXAxisStep += xAxisStepSize;
      }
      currentXAxisStep = -xAxisStepSize;
      for (var x = xOfZeroY - xStepOfXAxis; x >= 0; x -= xStepOfXAxis) {
        _paintAxisMarking(canvas, paint, labelTextStyle,
            currentXAxisStep.toString(), x, yOfZeroX, false);
        currentXAxisStep -= xAxisStepSize;
      }
    }
  }

  void _paintAxisMarking(
    ui.Canvas canvas,
    ui.Paint linePaint,
    ui.TextStyle labelTextStyle,
    String label,
    double x,
    double y,
    bool horizontal,
  ) {
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center),
    )
      ..pushStyle(
        ui.TextStyle(color: Colors.black),
      )
      ..addText(label);
    final paragraph = paragraphBuilder.build();

    paragraph.layout(
      const ui.ParagraphConstraints(width: double.infinity),
    );
    paragraph.layout(
      ui.ParagraphConstraints(width: paragraph.longestLine.ceilToDouble()),
    );
    if (horizontal) {
      canvas.drawParagraph(
          paragraph, Offset(x + 12.5, y - paragraph.height / 2));
    } else {
      canvas.drawParagraph(
        paragraph,
        Offset(x - paragraph.width / 2, y + 10),
      );
    }
    canvas.drawLine(
      Offset(horizontal ? x + 10 : x, horizontal ? y : y + 10),
      Offset(horizontal ? x - 10 : x, horizontal ? y : y - 10),
      linePaint,
    );
  }

  void paintGraph(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = graphsWidth
      ..strokeCap = StrokeCap.round;
    // ..blendMode = BlendMode.src;

    final stepSizeX = xOffset / size.width;
    final stepSizeY = yOffset / size.height;

    for (final functionAttributes in functions) {
      paint.color = functionAttributes.color;

      final f = functionAttributes.evaluatingFunction;
      final offsets = <Offset>[];

      var sizeX = 0.0;
      var x = this.x;
      while (sizeX < size.width) {
        final rawY = f(x);
        if (rawY.isNaN || rawY.isInfinite) {
          if (offsets.length < 2) {
            canvas.drawPoints(ui.PointMode.polygon, offsets, paint);
            offsets.clear();
          }
          continue;
        }
        final y = size.height - ((rawY - this.y) / stepSizeY);
        offsets.add(Offset(sizeX, y));
        sizeX++;
        x += stepSizeX;
      }
      if (offsets.isNotEmpty) {
        canvas.drawPoints(ui.PointMode.polygon, offsets, paint);
      }
    }
    // _rebuild++;
  }

  @override
  bool shouldRepaint(GraphsPainter oldDelegate) {
    return oldDelegate.x != x ||
        oldDelegate.y != y ||
        oldDelegate.xOffset != xOffset ||
        oldDelegate.yOffset != yOffset;
  }
  // static int _rebuild = 0;
  // static int _nonRebuild = 0;
  // @override
  // bool shouldRepaint(MathFunctionsPainter oldDelegate) {
  //   final rebuild = oldDelegate.x != x ||
  //       oldDelegate.y != y ||
  //       oldDelegate.xOffset != xOffset ||
  //       oldDelegate.yOffset != yOffset;
  //
  //   if (!rebuild) _nonRebuild++;
  //   print("rebuild: $_rebuild, non rebuilt: $_nonRebuild");
  //   return rebuild;
  // }

  static int _nextStepSize(int currentStepSize) {
    if (currentStepSize == 1) {
      return 2;
    } else if (currentStepSize == 2) {
      return 5;
    }
    return 1;
  }

  static double computeAxisStepSize(double axisRange) {
    //   axis steps 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000...
    //   has to be at least 10 to go to 2,
    //   has to be at least 5 to go to 1, etc
    //   => axis range multiplied by 10, must be bigger than range
    //   rawStepSize * 10^e is the axisStepSize
    var e = 0;
    var rawStepSize = 1; // either 1, 2 or 5
    if (axisRange >= 5) {
      while (rawStepSize * math.pow(10, e) * 10 <= axisRange) {
        if (rawStepSize == 5) {
          e++;
        }
        rawStepSize = _nextStepSize(rawStepSize);
      }
    } else {
      while (rawStepSize * math.pow(10, e) * 10 >= axisRange) {
        if (rawStepSize == 1) {
          e--;
        }
        rawStepSize = _nextStepSize(_nextStepSize(rawStepSize));
      }
      if (rawStepSize == 5 || rawStepSize == 2) {
        e++;
      }
      rawStepSize = _nextStepSize(_nextStepSize(rawStepSize));
    }
    return rawStepSize * math.pow(10, e).toDouble();
  }
}
