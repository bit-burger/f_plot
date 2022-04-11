import 'package:plotter/src/math/expr.dart';

import 'parser/options.dart';

class FunctionPlotter {
  final Expr _expr;

  FunctionPlotter._(this._expr);

  factory FunctionPlotter.fromLatexString(String s) {
    return FunctionPlotter.fromLatexStringWithOptions(s, ParserOptions());
  }

  factory FunctionPlotter.fromLatexStringWithOptions(
    String s,
    ParserOptions settings,
  ) {
    return FunctionPlotter._();
  }

  double y(double x) {
    return 0;
  }
}
