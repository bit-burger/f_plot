import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

const invalidExpressions = [
  "a +",
  "",
  "1 2",
  "()",
  " ^ b",
  "(asdf)(asdf)", //TODO: implicit operators
  "func a()",
  "a a",
  "(adf) (adf)",
  "func(adf) 3 (adf)",
  "func()",
  "func( )",
  "func( )func()",
  "func(,)",
  "func(a,b+)",
  "func(a,b,)",
  "+func(a,b)",
];

final validExpressions = [
  "a",
  "-a",
  " - - ---       --------------------------------func(-adsf (x) * 3, func(b))",
  "func(a + b+ c *d^3455)*fDj(1*1,0.)",
  "                1\n+123\n^h\n(a + \tb+ c *d              "
      "^\n\n\n345\t*5)*\nfDj  \n\n\n (1  *1\n\n,11,1,0.\n\n\n)     ",
  "func(a*c)*-----f",
  "-" * 1000 + "1",
];

void main() {
  final parser = StringExpressionParser();

  test("invalid expressions", () {
    for (final expression in invalidExpressions) {
      try {
        parser.parse(expression);
        fail("no error found on invalid expression '$expression'");
      } on StringExpressionParseError catch (e) {
        print("$expression        |        $e");
      }
    }
  });

  test("valid expressions", () {
    for (final expression in validExpressions) {
      expect(
        parser.parse(expression),
        parser.parse(parser.parse(expression).toString()),
      );
    }
  });
}
