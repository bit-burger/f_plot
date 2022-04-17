import 'dart:math';
import 'dart:typed_data';

import 'package:plotter/src/linear_plotter.dart';
import 'package:test/test.dart';

void main() {
  late final LinearPlotter plotter;

  setUp(() async {
    double f(double x) => pow(x, 2) as double;
    double fnc(double x) => x;

    plotter = LinearPlotter(
      beginX: 0,
      lastX: 5,
      stepSizeX: 1 / 4,
      functions: {"f": f, "fnc": fnc},
    );
  });

  test('basic testing', () async {
    plotter.compute();

    expect(plotter.functionValues, <String, Float64List>{
      "f": Float64List.fromList(
        Iterable.generate(
          21,
          (v) => pow(0.25 * v, 2) as double,
        ).toList(),
      ),
      "fnc": Float64List.fromList(
        Iterable.generate(
          21,
          (v) => 0.25 * v,
        ).toList(),
      ),
    });
  });
}
