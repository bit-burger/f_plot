class ExprStringRepresentation {
  final int firstChar;
  final int lastChar;

  const ExprStringRepresentation(this.firstChar, this.lastChar);
}

abstract class Expr {
  final ExprStringRepresentation? rep;

  const Expr(this.rep);

  double eval(double variableValue);
}

abstract class OneInputFunc extends Expr {
  final Expr expr;

  const OneInputFunc(this.expr, ExprStringRepresentation? rep) : super(rep);

  @override
  double eval(double variableValue) {
    return evalInput(expr.eval(variableValue));
  }

  double evalInput(double input);
}

abstract class TwoInputFunc extends Expr {
  final Expr expr1;
  final Expr expr2;

  const TwoInputFunc(this.expr1, this.expr2, ExprStringRepresentation? rep)
      : super(rep);

  @override
  double eval(double variableValue) {
    return evalInput(expr1.eval(variableValue), expr2.eval(variableValue));
  }

  double evalInput(double input1, double input2);
}

abstract class DynInputFunc extends Expr {
  final List<Expr> exprs;

  const DynInputFunc(this.exprs, ExprStringRepresentation? rep) : super(rep);
}
