import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  print(MathFunctionsPainter.computeAxisStepSize(2));
  print(MathFunctionsPainter.computeAxisStepSize(1.9));
  print(MathFunctionsPainter.computeAxisStepSize(9));
  print(MathFunctionsPainter.computeAxisStepSize(10));
  print(MathFunctionsPainter.computeAxisStepSize(20));
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
  static final allFunctions = [
    MathFunctionAttributes(
      evaluatingFunction: (x) => pow(x, 3) as double,
      color: Colors.blue,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => sin(x) * 2.5 + 20,
      color: Colors.red,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => x,
      color: Colors.green,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => -0.1 * pow(x, 3) + x + 0.01 * pow(x, 4),
      color: Colors.purple,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => cos(x) * 2.5 + 20,
      color: Colors.yellow,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => 7 * pow(0.5, x / 2).toDouble(),
      color: Colors.orange,
    ),
    MathFunctionAttributes(
      evaluatingFunction: (x) => log(x),
      name: "ln",
      color: Colors.black,
    ),
  ];

  final functions = <MathFunctionAttributes>[];
  void addFunction() {
    setState(() {
      functions.add(allFunctions.removeAt(0));
    });
  }

  final MathFunctionPlotterViewController functionPlotterViewController =
      MathFunctionPlotterViewController(
    x: -10,
    y: -10,
    xOffset: 40,
    yOffset: 40,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("example"),
      ),
      body: Stack(
        children: [
          MathFunctionPlotterView(
            controller: functionPlotterViewController,
            scrollAction: MathFunctionPlotterViewScrollAction.zoom,
            functions: functions,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: addFunction,
            child: Icon(Icons.add),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              functionPlotterViewController.applyZoomRatioToCenter(3 / 4);
              functionPlotterViewController.update();
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              functionPlotterViewController.applyZoomRatioToCenter(4 / 3);
              functionPlotterViewController.update();
            },
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

// TODO: maybe replace with extending a ValueNotifier<ui.Rect>
class MathFunctionPlotterViewController extends ChangeNotifier {
  double x;
  double y;
  double xOffset;
  double yOffset;

  MathFunctionPlotterViewController({
    required this.x,
    required this.y,
    required this.xOffset,
    required this.yOffset,
  });

  factory MathFunctionPlotterViewController.fromZero({
    required double width,
    required double height,
  }) {
    return MathFunctionPlotterViewController(
        x: 0, y: 0, xOffset: width, yOffset: height);
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

enum MathFunctionPlotterViewScrollAction {
  zoom,
  move,
  none;
}

class MathFunctionPlotterView extends StatefulWidget {
  final MathFunctionPlotterViewController? controller;

  final bool disablePanning;
  final bool showGrabCursorForMousePanning;
  final MathFunctionPlotterViewScrollAction scrollAction;

  final List<MathFunctionAttributes> functions;
  final double graphsWidth;

  final bool showAxis;
  final Color axisColor;
  final double axisWidth;
  final ui.TextStyle axisLabelsTextStyle;

  MathFunctionPlotterView({
    Key? key,
    this.controller,
    this.disablePanning = false,
    this.showGrabCursorForMousePanning = true,
    this.scrollAction = MathFunctionPlotterViewScrollAction.zoom,
    this.graphsWidth = 4,
    this.showAxis = true,
    this.axisColor = Colors.black,
    this.axisWidth = 2,
    TextStyle axisLabelsTextStyle = const TextStyle(color: Colors.black),
    required this.functions,
  })  : axisLabelsTextStyle = axisLabelsTextStyle.getTextStyle(),
        super(key: key);

  @override
  State<MathFunctionPlotterView> createState() =>
      _MathFunctionPlotterViewState();
}

class _MathFunctionPlotterViewState extends State<MathFunctionPlotterView> {
  late MathFunctionPlotterViewController? _controller;
  MathFunctionPlotterViewController get _effectiveController =>
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
      _controller = MathFunctionPlotterViewController.fromZero(
        width: 1,
        height: 1,
      );
    } else {
      _controller = null;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MathFunctionPlotterView oldWidget) {
    if (widget.controller != null && _controller != null) {
      _controller = null;
    } else {
      _controller ??= widget.controller;
      _controller ??= MathFunctionPlotterViewController.fromZero(
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
                MathFunctionPlotterViewScrollAction.none) {
              return;
            }
            if (event is PointerScrollEvent) {
              setState(() {
                final xSizeRatio = _effectiveController.xOffset / sizeWidth;
                final ySizeRatio = _effectiveController.yOffset / sizeHeight;
                if (widget.scrollAction ==
                    MathFunctionPlotterViewScrollAction.move) {
                  _effectiveController.x += event.scrollDelta.dx * xSizeRatio;
                  _effectiveController.y -= event.scrollDelta.dy * ySizeRatio;
                } else if (widget.scrollAction ==
                    MathFunctionPlotterViewScrollAction.zoom) {
                  // TODO: did not implement zoom correctly
                  final zoomRatio = 1 + (event.scrollDelta.dy / 200);
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
                  final currentUpperHeight = zoomPoint.dy;
                  final currentLowerHeight = sizeHeight - currentUpperHeight;
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
                  painter: MathFunctionsPainter(
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
  final double graphsWidth;

  final bool showAxis;
  final Color axisColor;
  final double axisWidth;
  final ui.TextStyle labelTextStyle;

  MathFunctionsPainter({
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
        Offset(0, yOfZeroX),
        Offset(size.width, yOfZeroX),
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
    Canvas canvas,
    Paint linePaint,
    ui.TextStyle labelTextStyle,
    String label,
    double x,
    double y,
    bool horizontal,
  ) {
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: TextAlign.center),
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
  bool shouldRepaint(MathFunctionsPainter oldDelegate) {
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
