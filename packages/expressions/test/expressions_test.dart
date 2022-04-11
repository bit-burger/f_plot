import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

void main() {
  final parser = RegularStringExpressionParser();

  group('values', () {
    test('number', () {
      expect(parser.parse("5"), Number(5));
    });

    test('decimal number', () {
      expect(parser.parse("5.4321"), Number(5.4321));
    });

    test('integer as decimal', () {
      expect(parser.parse("25."), Number(25));
    });

    test('integer as decimal with spacing', () {
      expect(parser.parse("  \n  16.333  \t  "), Number(16.333));
    });
  });

  group("operators", () {
    test('plus', () {
      expect(parser.parse("4+4"), OperatorCall("+", Number(4), Number(4)));
    });

    test('plus with spacing', () {
      expect(
        parser.parse("    99  +  100   "),
        OperatorCall("+", Number(99), Number(100)),
      );
    });

    test('multiple operators', () {
      expect(
        parser.parse("1*2*3*4"),
        OperatorCall(
          "*",
          Number(1),
          OperatorCall(
            "*",
            Number(2),
            OperatorCall(
              "*",
              Number(3),
              Number(4),
            ),
          ),
        ),
      );
    });

    test('operator precedence', () {
      expect(
        parser.parse("  4 \t*9+\n3.6   /6-\n22"),
        OperatorCall(
          "+",
          OperatorCall("*", Number(4), Number(9)),
          OperatorCall(
            "-",
            OperatorCall("/", Number(3.6), Number(6)),
            Number(22),
          ),
        ),
      );
    });
  });

  group("variables", () {
    test('simple variable', () {
      expect(parser.parse("aBc"), Variable("aBc"));
    });

    test('simple variable with spacing', () {
      expect(parser.parse("\n\taBc   \n"), Variable("aBc"));
    });

    test('variables with operator precedence', () {
      expect(
        parser.parse("a / b*c +1234"),
        OperatorCall(
          "+",
          OperatorCall(
            "/",
            Variable("a"),
            OperatorCall(
              "*",
              Variable("b"),
              Variable("c"),
            ),
          ),
          Number(1234),
        ),
      );
    });
  });

  group("brackets", () {
    test("one bracket", () {
      expect(parser.parse("(1)"), Number(1));
    });

    test("override operator precedence with brackets", () {
      expect(
        parser.parse("(1 + 5.) * (b)"),
        OperatorCall(
          "*",
          OperatorCall("+", Number(1), Number(5)),
          Variable("b"),
        ),
      );
    });

    test("more brackets", () {
      expect(
        parser.parse("(((1 + 5.)) * (b))"),
        OperatorCall(
          "*",
          OperatorCall("+", Number(1), Number(5)),
          Variable("b"),
        ),
      );
    });
  });

  group("functions", () {
    test('function with one number arg', () {
      expect(parser.parse("f(1)"), FunctionCall("f", [Number(1)]));
    });

    test('function with multiple args', () {
      expect(
        parser.parse("func(a,b,c)"),
        FunctionCall("func", [
          Variable("a"),
          Variable("b"),
          Variable("c"),
        ]),
      );
    });

    test('function with multiple args and spacing', () {
      expect(
        parser.parse("fnc \n  (\n \na   ,\nb\n,   c\n)"),
        FunctionCall("fnc", [
          Variable("a"),
          Variable("b"),
          Variable("c"),
        ]),
      );
    });
  });

  test('complicated expression', () {
    expect(
      parser.parse("asdf(x+y, (f^1.*6)) * (x + y)"),
      OperatorCall(
        "*",
        FunctionCall("asdf", [
          OperatorCall(
            "+",
            Variable("x"),
            Variable("y"),
          ),
          OperatorCall(
            "*",
            OperatorCall(
              "^",
              Variable("f"),
              Number(1),
            ),
            Number(6),
          )
        ]),
        OperatorCall(
          "+",
          Variable("x"),
          Variable("y"),
        ),
      ),
    );
  });
}
