import 'expr.dart';

class ConstantExpr extends Expr {
  final double constant;

  ConstantExpr(this.constant, ExprStringRepresentation? rep) : super(rep);

  @override
  double eval(Map<String, double> vars) {
    return constant;
  }
}
