import 'dart:async';
import 'dart:math';

import 'package:evaluator/evaluator.dart';
import 'dart:isolate';

class BinaryStreamIsolatePlotter {
  final int rangeBegin, rangeEnd;
  final int howManyDivides;
  final Map<String, EvaluatorFunction> functions;

  final int afterHowManyEventsNewStreamEvent;
  final int maxRangeWithOneIsolate;

  final bool broadcastStream;

  late Map<String, Map<double, double>> _functionsValues;
  late int _events;
  late int _expectedEvents;
  bool _computationStarted;
  late final StreamController<Map<String, Map<double, double>>>
      _streamController;

  Stream<Map<String, Map<double, double>>> get stream =>
      _streamController.stream;

  BinaryStreamIsolatePlotter({
    this.rangeBegin = 0,
    required this.rangeEnd,
    required this.functions,
    this.howManyDivides = 2,
    this.maxRangeWithOneIsolate = 8,
    this.afterHowManyEventsNewStreamEvent = 1,
    this.broadcastStream = false,
  })  : _computationStarted = false,
        assert(
          maxRangeWithOneIsolate == 2 || (maxRangeWithOneIsolate / 2) % 2 == 0,
          "should be a power of 2",
        );

  void beginComputation() {
    if (_computationStarted) {
      throw StateError("the computation has already begun");
    }
    if (broadcastStream) {
      _streamController = StreamController();
    } else {
      _streamController = StreamController.broadcast();
    }
    _events = 0;
    _expectedEvents = functions.length *
        (1 + (rangeEnd - rangeBegin) * pow(2, howManyDivides) as int);
    _functionsValues = Map.fromIterable(functions.keys, value: (_) => {});
    _computationStarted = true;
    for (final functionName in functions.keys) {
      final function = functions[functionName]!;
      _handleNewComputedValue(
        functionName,
        rangeBegin.toDouble(),
        function(rangeBegin.toDouble()),
      );
      var currentIsolateRangeBegin = rangeBegin;
      while (currentIsolateRangeBegin < rangeEnd) {
        var isolateRange = maxRangeWithOneIsolate;
        var howManyDivides = this.howManyDivides;
        while (currentIsolateRangeBegin + isolateRange > rangeEnd) {
          isolateRange ~/= 2;
        }
        howManyDivides += log2(isolateRange);
        final currentIsolateRangeEnd = currentIsolateRangeBegin + isolateRange;
        _beginComputationOfFunction(
          functionName,
          function,
          currentIsolateRangeBegin.toDouble(),
          currentIsolateRangeEnd.toDouble(),
          howManyDivides,
        );
        currentIsolateRangeBegin = currentIsolateRangeEnd;
      }
    }
  }

  void _beginComputationOfFunction(
    String functionName,
    EvaluatorFunction function,
    double begin,
    double end,
    int divides,
  ) async {
    final receivePort = ReceivePort();
    final expectedEvents = pow(2, divides);
    var receivedEvents = 0;
    late final StreamSubscription<Object?> receivePortSub;
    final isolate = await Isolate.spawn(
      _mainIsolate,
      _ComputationMessage(
        function,
        begin,
        end,
        divides,
        receivePort.sendPort,
      ),
    );
    receivePortSub = receivePort.listen((message) {
      final list = message as List<double>;
      _handleNewComputedValue(functionName, list[0], list[1]);
      receivedEvents++;
      if (receivedEvents == expectedEvents) {
        //TODO: not sure if fixed
        isolate.kill(priority: Isolate.immediate);
        receivePortSub.cancel();
      }
    });
  }

  static void _mainIsolate(_ComputationMessage message) {
    void evaluate(double x) {
      final y = message.function(x);
      message.sendPort.send([x, y]);
    }

    void evaluateAndDivide(double begin, double end, int depth) {
      if (depth == message.divides) return;
      final first = begin;
      final second = (begin + end) / 2;
      evaluateAndDivide(first, second, depth + 1);
      evaluate(second);
      evaluateAndDivide(second, end, depth + 1);
    }

    evaluate(message.end);
    evaluateAndDivide(message.begin, message.end, 0);
  }

  void _handleNewComputedValue(String functionName, double x, double y) {
    _functionsValues[functionName]![x] = y;
    _events++;
    if (_events == _expectedEvents) {
      _streamController.add(_functionsValues);
      _streamController.close();
    } else if (_events % afterHowManyEventsNewStreamEvent == 0) {
      _streamController.add(_functionsValues);
    }
  }

  static int log2(int n) {
    var i = 0;
    while (n > 1) {
      n ~/= 2;
      i++;
    }
    return i;
  }
}

class _ComputationMessage {
  final EvaluatorFunction function;
  final double begin;
  final double end;
  final int divides;
  final SendPort sendPort;

  _ComputationMessage(
    this.function,
    this.begin,
    this.end,
    this.divides,
    this.sendPort,
  );
}
