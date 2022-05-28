import "dart:math" as math show pow ;

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
  return a / b;
}

double pow(double a, double b) {
  return math.pow(a, b) as double;
}
