import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
        title: Text("example"),
      ),
      body: RawGestureDetector(
        gestures: {
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                  (TapGestureRecognizer instance) {
            instance.onSecondaryTapUp = (TapUpDetails details) {
              setState(() {
                x += 10;
                y += 10;
                xOffset -= 20;
                yOffset -= 20;
              });
            };
          }),
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: FaceOutlinePainter(x, y, xOffset, yOffset),
          ),
        ),
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

    final offsets = <Offset>[];
    var sizeX = 0.0;
    var functionX = x;
    final path = Path();
    while (sizeX < size.width) {
      final y = f(functionX);
      offsets.add(Offset(sizeX, y));
      sizeX++;
      functionX += stepSizeX;
    }
    // path.close();
    // canvas.drawPath(path, paint);
    canvas.drawPoints(PointMode.polygon, offsets, paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) =>
      oldDelegate.x != x ||
      oldDelegate.y != y ||
      oldDelegate.xOffset != xOffset ||
      oldDelegate.yOffset != yOffset;
}
