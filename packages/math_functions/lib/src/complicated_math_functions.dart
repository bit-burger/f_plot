import 'dart:math' show pow;
import 'dart:math' as math show log;

export "dart:math" show sqrt;

double root(double a, double b) {
  return pow(a, 1.0 / b) as double;
}

double estimateRoot(double a, double b) {
  var r = 1.0;
  for (var i = 0; i < 3; i++) {
    r -= (pow(r, b) - a) / (b * pow(r, b - 1));
  }
  return r;
}

double log(double a, double b) {
  if (a < 0 || b < 0) {
    return double.nan;
  }
  return math.log(a) / math.log(b);
}

double estimateLog(double a, double b) {
  // TODO: implement or remove method
  throw UnimplementedError();
}
