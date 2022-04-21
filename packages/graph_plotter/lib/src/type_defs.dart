import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef GraphFunction = double Function(double x);

class GraphAttributes {
  final GraphFunction evaluatingFunction;
  final String? name;
  final ui.Color color;

  const GraphAttributes({
    required this.evaluatingFunction,
    this.name,
    this.color = Colors.black,
  });
}


