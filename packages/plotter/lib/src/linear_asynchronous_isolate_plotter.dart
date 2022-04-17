import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:evaluator/evaluator.dart';

class LinearAsynchronousIsolatePlotter {
  final double beginX, lastX;
  final double stepSizeX;
  final Map<String, EvaluatorFunction> functions;
  final int _howManyComputations;

  late final Map<String, Float64List> functionValues;
  bool _computationStarted;

  LinearAsynchronousIsolatePlotter({
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

  Future<void> compute() async {
    if (_computationStarted) {
      throw StateError("the computation has already begun");
    }
    _computationStarted = true;
    functionValues = {};

    await Future.wait(functions.keys
        .map((functionName) => _startComputingForFunction(functionName)));

    for (final functionName in functions.keys) {
      _startComputingForFunction(functionName);
    }
  }

  Future<void> _startComputingForFunction(String functionName) async {
    final completer = Completer<void>();
    final receivePort = ReceivePort();
    late final StreamSubscription<Object?> receivePortSub;
    final message = _ComputationMessage(
      functions[functionName]!,
      beginX,
      lastX,
      stepSizeX,
      _howManyComputations,
      receivePort.sendPort,
    );
    final isolate = await Isolate.spawn(isolateMain, message);
    receivePortSub = receivePort.listen((message) {
      final list = message as Float64List;
      functionValues[functionName] = list;
      completer.complete();
      isolate.kill(priority: Isolate.immediate);
      receivePortSub.cancel();
    });
    return completer.future;
  }

  static void isolateMain(_ComputationMessage message) {
    final list = Float64List(message.howManyComputations);
    var i = 0;
    var x = message.beginX;
    while (x <= message.lastX) {
      list[i] = message.function(x);
      i++;
      x += message.stepSizeX;
    }
    message.sendPort.send(list);
  }
}

class _ComputationMessage {
  final EvaluatorFunction function;
  final double beginX, lastX;
  final double stepSizeX;
  final int howManyComputations;
  final SendPort sendPort;

  _ComputationMessage(
    this.function,
    this.beginX,
    this.lastX,
    this.stepSizeX,
    this.howManyComputations,
    this.sendPort,
  );
}
