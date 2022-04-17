import 'dart:math';

import 'package:plotter/src/binary_stream_isolate_plotter.dart';
import 'package:test/test.dart';

void main() {
  late final BinaryStreamIsolatePlotter plotter;

  setUp(() async {
    double f(double x) => pow(x, 2) as double;
    double fnc(double x) => x;

    plotter = BinaryStreamIsolatePlotter(
      rangeEnd: 5,
      howManyDivides: 2,
      afterHowManyEventsNewStreamEvent: 1000,
      maxRangeWithOneIsolate: 2,
      functions: {"f": f, "fnc": fnc},
    );
  });

  test('basic stream testing', () {
    plotter.beginComputation();
    expect(
      plotter.stream,
      emitsInOrder(
        [
          <String, Map<double, double>>{
            "f": Map.fromIterable(
              Iterable.generate(21, (v) => 0.25 * v),
              value: (v) => pow(v, 2) as double,
            ),
            "fnc": Map.fromIterable(
              Iterable.generate(21, (v) => 0.25 * v),
              value: (v) => v,
            ),
          },
          emitsDone,
        ],
      ),
    );
  });
}
