import '../math/expr.dart';

abstract class EvalError implements Exception {}

abstract class ArgumentError implements EvalError {
  final Expr funcExpr;
  final List<Expr> errorCausingArguments;
  final String errorMessage;

  ArgumentError({
    required this.funcExpr,
    this.errorCausingArguments = const [],
    required this.errorMessage,
  });

  @override
  String toString() {
    var s = "ERROR EVALUATING: '$errorMessage'";
    if (funcExpr.rep != null) {
      s += " at character ${funcExpr.rep!.firstChar} "
          "to character ${funcExpr.rep!.firstChar}";
    }
    return s;
  }

  String getExpr(String fullString) {
    final rep = funcExpr.rep;
    if (rep != null) {
      return fullString.substring(rep.firstChar, rep.lastChar + 1);
    }
    throw UnsupportedError("Can only call this method of an ArgumentError, "
        "that has been created with the ParserOptions "
        "having generateRepsForExpressions turned on");
  }
}

class OverflowError implements EvalError {
  final double howMuch;

  OverflowError(this.howMuch);
  @override
  String toString() {
    return "overflowed by $howMuch";
  }
}
