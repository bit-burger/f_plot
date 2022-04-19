import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
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
  double x = -10, y = 40;
  double xOffset = 50, yOffset = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("example"),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
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
              return GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    x -= details.delta.dx * xSizeRatio;
                    y -= details.delta.dy * ySizeRatio;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: FaceOutlinePainter(x, y, xOffset, yOffset),
                  ),
                ),
              );
            },
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
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  // static double f(double x) => sin(x / 10) * 10 + 20;
  static double f(double x) => pow(x, 2) as double;

  final double x, y;
  final double xOffset, yOffset;

  const FaceOutlinePainter(this.x, this.y, this.xOffset, this.yOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.indigo;

    final stepSizeX = xOffset / size.width;
    final stepSizeY = yOffset / size.height;

    final offsets = <Offset>[];
    var sizeX = 0.0;
    var functionX = x;
    while (sizeX < size.width) {
      final rawY = f(functionX);
      final y = size.height - ((rawY + this.y) / stepSizeY);
      offsets.add(Offset(sizeX, y));
      sizeX++;
      functionX += stepSizeX;
    }
    canvas.drawPoints(PointMode.polygon, offsets, paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) =>
      oldDelegate.x != x ||
      oldDelegate.y != y ||
      oldDelegate.xOffset != xOffset ||
      oldDelegate.yOffset != yOffset;
}
