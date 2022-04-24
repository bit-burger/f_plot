import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_plotter/graph_plotter.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme().apply(displayColor: Colors.white),
      ),
      home: const GraphPlotterTest(),
    ),
  );
}

class GraphPlotterTest extends StatefulWidget {
  const GraphPlotterTest({Key? key}) : super(key: key);

  @override
  State<GraphPlotterTest> createState() => _GraphPlotterTestState();
}

final someGraphs = [
  GraphAttributes(
    name: "x^3",
    color: Colors.blue.shade300,
    evaluatingFunction: (x) => pow(x, 3) as double,
  ),
  GraphAttributes(
    name: "sin(x) * 2.5 + 20",
    evaluatingFunction: (x) => sin(x) * 2.5 + 20,
    color: Colors.red.shade300,
  ),
  GraphAttributes(
    name: "x",
    evaluatingFunction: (x) => x,
    color: Colors.green.shade300,
  ),
  GraphAttributes(
    name: "-0.1x^3+x+0.01x^4",
    evaluatingFunction: (x) => -0.1 * pow(x, 3) + x + 0.01 * pow(x, 4),
    color: Colors.purple.shade300,
  ),
  GraphAttributes(
    name: "cos(x)*2.5*20",
    evaluatingFunction: (x) => cos(x) * 2.5 + 20,
    color: Colors.yellow.shade300,
  ),
  GraphAttributes(
    name: "7*(1/2)^(x/2)",
    evaluatingFunction: (x) => 7 * pow(0.5, x / 2).toDouble(),
    color: Colors.orange.shade300,
  ),
  GraphAttributes(
    name: "x^2 with a gap from [2;-2]",
    evaluatingFunction: (x) {
      if (x >= -2 && x <= 2) {
        return double.nan;
      } else if (x > 2) {
        return pow(x - 2, 2).toDouble() + 5.0;
      } else {
        return pow(x + 2, 2).toDouble() + 5.0;
      }
    },
    color: Colors.white,
  ),
  // TODO: functions (x-2) % 5 + 5 and ln(x) displayed badly
  GraphAttributes(
    name: "(x-2) % 5 + 5",
    evaluatingFunction: (x) => (x - 2) % 5 + 5,
    color: Colors.cyan.shade300,
  ),
  GraphAttributes(
    evaluatingFunction: (x) {
      if (x <= 0) {
        return double.nan;
      }
      return log(x);
    },
    name: "ln(x)",
    color: Colors.grey,
  ),
];

class _GraphPlotterTestState extends State<GraphPlotterTest> {
  final graphsA = [...someGraphs];
  final graphsB = <GraphAttributes>[];
  var fromAToB = true;

  GraphsPainterQuality? quality;

  void lowerQuality() {
    setState(() {
      if(quality == null) {
        quality = GraphsPainterQuality.high;
      } else if(quality == GraphsPainterQuality.extremelyLow) {
        quality = null;
      } else {
        quality = quality!.before;
      }
    });
  }

  /// either move first graph from [graphsA] to [graphsB]
  /// or from [graphsB] to [graphsA] depending on [fromAToB].
  ///
  /// [fromAToB] will then be toggled if [graphsA] or [graphsB] is empty
  void addFunction() {
    setState(() {
      if (fromAToB) {
        if (graphsA.isEmpty) {
          graphsA.add(graphsB.removeAt(0));
          fromAToB = false;
        } else {
          graphsB.add(graphsA.removeAt(0));
        }
      } else {
        if (graphsB.isEmpty) {
          graphsB.add(graphsA.removeAt(0));
          fromAToB = true;
        } else {
          graphsA.add(graphsB.removeAt(0));
        }
      }
    });
  }

  final GraphPlotterController functionPlotterViewController =
      GraphPlotterController(
    x: -10,
    y: -10,
    xOffset: 40,
    yOffset: 40,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GraphPlotter(
            quality: quality,
            showAxis: true,
            axisWidth: 2.0,
            graphsWidth: 3.0,
            axisColor: Colors.white,
            axisLabelsTextStyle: const TextStyle(color: Colors.white),
            controller: functionPlotterViewController,
            scrollAction: GraphPlotterScrollAction.zoom,
            graphs: graphsB,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            tooltip: "quality",
            onPressed: lowerQuality,
            label: Text(
              quality == null ? "automatic" : quality!.getStepSize().toString(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            tooltip: "add or remove function",
            onPressed: addFunction,
            child: const Icon(Icons.functions),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            tooltip: "zoom in",
            onPressed: () {
              functionPlotterViewController.applyZoomRatioToCenter(3 / 4);
              functionPlotterViewController.update();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            tooltip: "zoom out",
            onPressed: () {
              functionPlotterViewController.applyZoomRatioToCenter(4 / 3);
              functionPlotterViewController.update();
            },
            child: const Icon(Icons.remove),
          ),

        ],
      ),
    );
  }
}
