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

    test('negative number', () {
      expect(
        parser.parse("  \n  -16.333  \t  "),
        NegateOperator(Number(16.333)),
      );
    });
  });

  group("operators", () {
    test('plus', () {
      expect(parser.parse("4+4"), OperatorCall("+", Number(4), Number(4)));
    });

    test('minus', () {
      expect(parser.parse("4-4"), OperatorCall("-", Number(4), Number(4)));
    });

    test('negated minus', () {
      expect(
        parser.parse("4--4"),
        OperatorCall("-", Number(4), NegateOperator(Number(4))),
      );
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
          OperatorCall(
            "*",
            OperatorCall(
              "*",
              Number(1),
              Number(2),
            ),
            Number(3),
          ),
          Number(4),
        ),
      );
    });

    test('operator precedence and negation', () {
      expect(
        parser.parse("  4 \t*9+\n-3.6   /6-\n--22"),
        OperatorCall(
          "-",
          OperatorCall(
            "+",
            OperatorCall("*", Number(4), Number(9)),
            NegateOperator(OperatorCall("/", Number(3.6), Number(6))),
          ),
          NegateOperator(
            NegateOperator(
              Number(22),
            ),
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
            "*",
            OperatorCall(
              "/",
              Variable("a"),
              Variable("b"),
            ),
            Variable("c"),
          ),
          Number(1234),
        ),
      );
    });

    test("variable negation", () {
      expect(
        parser.parse("-a* -b"),
        NegateOperator(
          OperatorCall(
            "*",
            Variable("a"),
            NegateOperator(Variable("b")),
          ),
        ),
      );
    });

    test("variable and numbers complicated operators with negation", () {
      expect(
        parser.parse("-0 +- -b"),
        OperatorCall(
          "+",
          NegateOperator(
            Number(0),
          ),
          NegateOperator(
            NegateOperator(
              Variable("b"),
            ),
          ),
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
        parser.parse("(1 + 5.) * (-b)"),
        OperatorCall(
          "*",
          OperatorCall("+", Number(1), Number(5)),
          NegateOperator(Variable("b")),
        ),
      );
    });

    test("more brackets", () {
      expect(
        parser.parse("(-((1 + 5.)) * (b))"),
        NegateOperator(
          OperatorCall(
            "*",
            OperatorCall("+", Number(1), Number(5)),
            Variable("b"),
          ),
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

  test('complicated expression with variable and function analysing', () {
    final expression = parser.parse("- asdf(x+y, (f^1.*6)) * (x + y) * -3");
    expect(
      expression,
      NegateOperator(
        OperatorCall(
          "*",
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
          NegateOperator(Number(3)),
        ),
      ),
    );
    expect(expression.referencedVariables, {"x", "y", "f"});
    expect(expression.referencedFunctions, {"asdf"});
  });
}
