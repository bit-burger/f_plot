export "dart:math" show pow;

double sum(double a, double b) {
  return a + b;
}

double minus(double a, double b) {
  return a - b;
}

double multiply(double a, double b) {
  return a * b;
}

double divide(double a, double b) {
  final res = a * b;
  if (res.isInfinite) {
    return double.nan;
  }
  return res;
}
