import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_plotter/graph_plotter.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GraphPlotterTest(),
    ),
  );
}

class GraphPlotterTest extends StatefulWidget {
  const GraphPlotterTest({Key? key}) : super(key: key);

  @override
  State<GraphPlotterTest> createState() => _GraphPlotterTestState();
}

class _GraphPlotterTestState extends State<GraphPlotterTest> {
  final graphsA = [
    GraphAttributes(
      name: "x^3",
      color: Colors.blue,
      evaluatingFunction: (x) => pow(x, 3) as double,
    ),
    GraphAttributes(
      name: "sin(x) * 2.5 + 20",
      evaluatingFunction: (x) => sin(x) * 2.5 + 20,
      color: Colors.red,
    ),
    GraphAttributes(
      name: "x",
      evaluatingFunction: (x) => x,
      color: Colors.green,
    ),
    GraphAttributes(
      name: "-0.1x^3+x+0.01x^4",
      evaluatingFunction: (x) => -0.1 * pow(x, 3) + x + 0.01 * pow(x, 4),
      color: Colors.purple,
    ),
    GraphAttributes(
      name: "cos(x)*2.5*20",
      evaluatingFunction: (x) => cos(x) * 2.5 + 20,
      color: Colors.yellow,
    ),
    GraphAttributes(
      name: "7*(1/2)^(x/2)",
      evaluatingFunction: (x) => 7 * pow(0.5, x / 2).toDouble(),
      color: Colors.orange,
    ),
    // TODO: function still not compatible
    // MathFunctionAttributes(
    //   evaluatingFunction: (x) {
    //     if (x <= 0) {
    //       return double.nan;
    //     }
    //     return log(x);
    //   },
    //   name: "ln",
    //   color: Colors.black,
    // ),
  ];

  final graphsB = <GraphAttributes>[];
  var fromAToB = true;

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
      appBar: AppBar(
        title: const Text("example"),
      ),
      body: Stack(
        children: [
          GraphPlotter(
            controller: functionPlotterViewController,
            scrollAction: GraphPlotterScrollAction.zoom,
            functions: graphsB,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: addFunction,
            child: const Icon(Icons.functions),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              functionPlotterViewController.applyZoomRatioToCenter(3 / 4);
              functionPlotterViewController.update();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
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
