import 'dart:typed_data';

import 'package:evaluator/evaluator.dart';

class LinearPlotter {
  final double beginX, lastX;
  final double stepSizeX;
  final Map<String, EvaluatorFunction> functions;
  final int _howManyComputations;

  late final Map<String, Float64List> functionValues;
  bool _computationStarted;

  LinearPlotter({
    this.beginX = 0,
    required this.lastX,
    this.stepSizeX = 0.1,
    required this.functions,
  })  : _computationStarted = false,
        _howManyComputations = (lastX - beginX) ~/ stepSizeX + 1,
        assert(
          lastX - beginX > 0,
          "interval between lastX and beginX should be greater than 0",
        ),
        assert(
          (lastX - beginX) % stepSizeX == 0,
          "n * stepSizeX should be lastX - beginX, "
          "with n being a natural number",
        );

  void compute() {
    if (_computationStarted) {
      throw StateError("the computation has already begun");
    }
    _computationStarted = true;
    functionValues = Map.fromIterable(
      functions.keys,
      value: (_) => Float64List(_howManyComputations),
    );

    for (final name in functions.keys) {
      var i = 0;
      var x = beginX;
      while (x <= lastX) {
        functionValues[name]![i] = functions[name]!(x);
        i++;
        x += stepSizeX;
      }
    }
  }
}
