import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// the f(x) definition of a graph
typedef GraphFunction = double Function(double x);

/// represents a graph
class GraphAttributes {
  /// the mathematical function that defines the graph, such as f(x) = x^2
  final GraphFunction evaluatingFunction;

  /// the name of the graph, not currently used
  final String? name;

  /// the color of the graph
  final ui.Color color;

  const GraphAttributes({
    required this.evaluatingFunction,
    this.name,
    this.color = Colors.black,
  });
}
