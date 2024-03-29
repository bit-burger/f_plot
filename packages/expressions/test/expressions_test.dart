import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

void main() {
  final parser = StringExpressionParser();

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

  group("simplifying", () {
    test("adding numbers", () {
      expect(
        parser.parse("2 + 2").simplify(),
        Number(4),
      );
    });

    test("more complicated arithmetic", () {
      expect(
        parser.parse("2*4^2. + -2").simplify(),
        Number(30),
      );
    });

    test("negation simplifying", () {
      expect(
        parser.parse("-(-a-b)").simplify(),
        OperatorCall("+", Variable("a"), Variable("b")),
      );
    });

    test("non simplifiable function call", () {
      final e = parser.parse("func(1+2, 1+b)");
      expect(
        e,
        FunctionCall(
          "func",
          [
            OperatorCall(
              "+",
              Number(1),
              Number(2),
            ),
            OperatorCall(
              "+",
              Number(1),
              Variable("b"),
            ),
          ],
        ),
      );
      expect(
        e.resolve(ResolveContext.custom(functions: {"func": (l) => 0})),
        FunctionCall(
          "func",
          [
            Number(3),
            OperatorCall(
              "+",
              Number(1),
              Variable("b"),
            ),
          ],
        ),
      );
    });

    test("easily simplifiable function call", () {
      final e = parser.parse("pow (5.*\n5.0, sqrt(4)) / 2");
      expect(
        e,
        OperatorCall(
          "/",
          FunctionCall(
            "pow",
            [
              OperatorCall(
                "*",
                Number(5),
                Number(5),
              ),
              FunctionCall(
                "sqrt",
                [
                  Number(4),
                ],
              ),
            ],
          ),
          Number(2),
        ),
      );
      expect(
        e.resolve(
          ResolveContext.custom(
            functions: {
              "sqrt": (l) => sqrt(l[0]),
              "pow": (l) {
                return pow(l[0], l[1]) as double;
              }
            },
          ),
        ),
        Number(625 / 2),
      );
    });

    test("insert into variables", () {
      final a = OperatorCall(
        "+",
        Variable("x"),
        Variable("l"),
      );
      final b = OperatorCall(
        "*",
        OperatorCall(
          "^",
          Variable("f"),
          Number(1),
        ),
        Number(6),
      );
      final expression = parser.parse("- asdf(a, 2*b)");
      expect(
        expression.copyWithInsertVariables({"a": a, "b": b}),
        NegateOperator(
          FunctionCall(
            "asdf",
            [
              a,
              OperatorCall("*", Number(2), b),
            ],
          ),
        ),
      );
    });

    test("complex function insert", () {
      // use the function 'f' for insertion and for calling,
      // as it is called with variables and with numbers

      // first expect by giving the context a insertion function
      // and a resolving function for 'f'

      // second expect by giving the context only the insertion function

      // both tests should result in the same Expression been given back
      final expression = parser.parse("-\n- f (x, timesFour(f(2, 4)) + pi)");
      final contextFunctions = {
        "timesFour": (List<double> l) => 4 * l[0],
        "f": (List<double> l) => l[0] + 2 * l[1],
      };
      final contextInsertFunctions = {
        "f": ExpressionInsertFunction(
          expression: parser.parse("x + 2*y"),
          parameterNames: ["x", "y"],
        ),
      };
      final contextVariables = {
        "pi": pi,
      };

      final expected = parser.parse("x + 2*(40 + $pi)").simplify();
      // with insertion function and resolving function for 'f'
      expect(
        expression.copy().resolve(
              ResolveContext.custom(
                functions: contextFunctions,
                insertFunctions: contextInsertFunctions,
                variables: contextVariables,
              ),
            ),
        expected,
      );
      // only with insertion function for 'f'
      expect(
        expression.copy().resolve(
              ResolveContext.custom(
                functions: contextFunctions
                  ..removeWhere(
                    (key, value) => key == "f",
                  ),
                insertFunctions: contextInsertFunctions,
                variables: contextVariables,
              ),
            ),
        expected,
      );
    });
  });

  test('Complicated variable resolving', () {
    // not working yet, need to improve resolving
    final expression = parser.parse("a + 1 + 1");
    expect(expression.simplify(), parser.parse("a + 2"));
  }, skip: true);

  test('ResolveContext overriding variables', () {
    final expression = parser.parse("1 + a + b");
    final context = ResolveContext.custom(variables: {"a": 2, "b": 2});
    final expectedExpression = parser.parse("3 + b");
    expect(expression.resolve(context, {"b"}), expectedExpression);
  });

  test('resolve to a number', () {
    final context = ResolveContext.custom(
      insertFunctions: {
        "f": ExpressionInsertFunction(
          parameterNames: ["a", "b"],
          expression: parser.parse("a + 2 * b"),
        ),
        "g": ExpressionInsertFunction(
          parameterNames: ["a", "f"],
          expression: parser.parse("a + 2 * f + c"),
        ),
      },
      functions: {
        "h": (List<double> args) => args[0] + 5,
      },
      variables: {
        "a": 1,
        "b": 2,
        "c": 3,
      },
    );
    // f(a, 0.25) = 1.5
    // g(1, 5)    = 14
    // h(c)       = 8
    //          * = 3150
    final expression = parser.parse("f(a, 0.25) * g(1, 5) * h(c)");
    expect(expression.resolveToNumber(context), 168);
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
