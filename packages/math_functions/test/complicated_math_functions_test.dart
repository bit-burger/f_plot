import 'package:math_functions/math_functions.dart';
import 'package:test/test.dart';

void main() {
  test("complex root exact", () {
    expect(root(16, 2 / 3), 64);
  });

  test("simple root estimate", () {
    expect(estimateRoot(-8, 3), -2);
  });

  test("complex root estimate", () {
    expect(estimateRoot(10, 5 / 3), closeTo(3.981071706, 0.01));
  });

  test("simple log exact", () {
    expect(log(1 / 1000, 10), closeTo(-3, 1 / 10000));
  });
}
