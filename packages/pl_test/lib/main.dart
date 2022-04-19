import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  print(MathFunctionsPainter.axisStep(2));
  print(MathFunctionsPainter.axisStep(1.9));
  print(MathFunctionsPainter.axisStep(9));
  print(MathFunctionsPainter.axisStep(10));
  print(MathFunctionsPainter.axisStep(20));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool zoomedByDoubleTap = false;
  double x = -10, y = -10;
  double xOffset = 40, yOffset = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("example"),
      ),
      body: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // print(
                //   "y: ${this.y} - ${this.y + yOffset} | "
                //   "x: ${this.x} - ${this.x + xOffset}",
                // );
                final size = constraints.biggest;
                final sizeWidth = size.width;
                final sizeHeight = size.height;
                final xSizeRatio = xOffset / sizeWidth;
                final ySizeRatio = yOffset / sizeHeight;
                return Listener(
                  onPointerSignal: (event) {
                    if(event is PointerScrollEvent) {
                      setState(() {
                        x += event.scrollDelta.dx * xSizeRatio;
                        y -= event.scrollDelta.dy * ySizeRatio;
                      });
                    }
                  },
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        x -= details.delta.dx * xSizeRatio;
                        y += details.delta.dy * ySizeRatio;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: MathFunctionsPainter(
                          x: x,
                          y: y,
                          xOffset: xOffset,
                          yOffset: yOffset,
                          functions: [
                            MathFunctionAttributes(
                              evaluatingFunction: (x) => pow(x, 3) as double,
                              color: Colors.blue,
                            ),
                            MathFunctionAttributes(
                              evaluatingFunction: (x) => sin(x) * 2.5 + 20,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("(${x.toStringAsFixed(1)}|${y.toStringAsFixed(1)})"),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                final middleX = x + xOffset / 2;
                final middleY = y + yOffset / 2;
                xOffset = xOffset * 0.75;
                yOffset = yOffset * 0.75;
                x = middleX - xOffset / 2;
                y = middleY - yOffset / 2;
              });
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                final middleX = x + xOffset / 2;
                final middleY = y + yOffset / 2;
                xOffset = xOffset / 0.75;
                yOffset = yOffset / 0.75;
                x = middleX - xOffset / 2;
                y = middleY - yOffset / 2;
              });
            },
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

typedef MathFunction = double Function(double x);

class MathFunctionAttributes {
  final MathFunction evaluatingFunction;
  final String? name;
  final Color color;

  const MathFunctionAttributes({
    required this.evaluatingFunction,
    this.name,
    this.color = Colors.black,
  });
}

class MathFunctionsPainter extends CustomPainter {
  final double x, y;
  final double xOffset, yOffset;
  // make sure functions is rebuilt if changes
  final List<MathFunctionAttributes> functions;
  final double functionsGraphWidth;

  final bool showAxis;
  final Color axisColor;
  final double axisWidth;
  // final Paint? graphPaint;
  // final Paint? axisPaint;

  const MathFunctionsPainter({
    this.x = 0,
    this.y = 0,
    this.xOffset = 1,
    this.yOffset = 1,
    required this.functions,
    this.functionsGraphWidth = 4,
    this.showAxis = true,
    this.axisColor = Colors.black,
    this.axisWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showAxis) {
      paintAxis(canvas, size);
    }
    paintGraph(canvas, size);
  }

  void paintAxis(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = axisColor
      ..strokeWidth = axisWidth;
    // y-axis
    final stepSizeX = xOffset / size.width;
    final xOfZeroY = -this.x / stepSizeX;
    final stepSizeY = yOffset / size.height;
    final yOfZeroX = size.height - (-this.y / stepSizeY);
    if (x <= 0 && 0 <= x + xOffset) {
      canvas.drawLine(
        Offset(xOfZeroY, 0),
        Offset(xOfZeroY, size.height),
        paint,
      );
      final yStepOfYAxis = axisStep(yOffset) / stepSizeY;
      for (var y = yOfZeroX; y <= size.height; y += yStepOfYAxis) {
        canvas.drawLine(
          Offset(xOfZeroY + 10, y),
          Offset(xOfZeroY - 10, y),
          paint,
        );
      }
      for (var y = yOfZeroX; y >= 0; y -= yStepOfYAxis) {
        canvas.drawLine(
          Offset(xOfZeroY + 10, y),
          Offset(xOfZeroY - 10, y),
          paint,
        );
      }
    }
    // x-axis
    if (y <= 0 && 0 <= y + yOffset) {
      canvas.drawLine(
        Offset(0, yOfZeroX),
        Offset(size.width, yOfZeroX),
        paint,
      );
      final xStepOfXAxis = axisStep(xOffset) / stepSizeX;
      for (var x = xOfZeroY; x <= size.width; x += xStepOfXAxis) {
        canvas.drawLine(
          Offset(x, yOfZeroX + 10),
          Offset(x, yOfZeroX - 10),
          paint,
        );
      }
      for (var x = xOfZeroY; x >= 0; x -= xStepOfXAxis) {
        canvas.drawLine(
          Offset(x, yOfZeroX + 10),
          Offset(x, yOfZeroX - 10),
          paint,
        );
      }
    }
  }

  void paintGraph(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = functionsGraphWidth;

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
        final y = size.height - ((rawY - this.y) / stepSizeY);
        offsets.add(Offset(sizeX, y));
        sizeX++;
        x += stepSizeX;
      }
      canvas.drawPoints(PointMode.polygon, offsets, paint);
    }
  }

  // TODO: add extra repaint property, to force rebuild from parent if it isn't one of the 4 lower properties being changed
  @override
  bool shouldRepaint(MathFunctionsPainter oldDelegate) =>
      oldDelegate.x != x ||
      oldDelegate.y != y ||
      oldDelegate.xOffset != xOffset ||
      oldDelegate.yOffset != yOffset;

  static int _nextStepSize(int currentStepSize) {
    if (currentStepSize == 1) {
      return 2;
    } else if (currentStepSize == 2) {
      return 5;
    }
    return 1;
  }

  static double axisStep(double axisRange) {
    //   axis steps 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000...
    //   has to be at least 10 to go to 2,
    //   has to be at least 5 to go to 1, etc
    //   => axis range multiplied by 10, must be bigger than range
    //   rawStepSize * 10^e is the axisStepSize
    var e = 0;
    var rawStepSize = 1; // either 1, 2 or 5
    if (axisRange >= 5) {
      while (rawStepSize * pow(10, e) * 10 <= axisRange) {
        if (rawStepSize == 5) {
          e++;
        }
        rawStepSize = _nextStepSize(rawStepSize);
      }
    } else {
      while (rawStepSize * pow(10, e) * 10 >= axisRange) {
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
    return rawStepSize * pow(10, e).toDouble();
  }
}
