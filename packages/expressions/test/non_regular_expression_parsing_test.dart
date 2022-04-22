import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

void main() {
  final context = ParserContext({"fnc": 3, "f": 1}, {"a", "b", "c"});
  final parser = StringExpressionParser();

  test('simple variable', () {
    expect(
      parser.parse("a + b + fnc(1, 34., 5)", context),
      OperatorCall(
        "+",
        OperatorCall("+", Variable("a"), Variable("b")),
        FunctionCall(
          "fnc",
          [Number(1), Number(34), Number(5)],
        ),
      ),
    );
  });

  test('variable does not exist', () {
    expect(
      () => parser.parse("a + d", context),
      throwsA(TypeMatcher<StringExpressionParseError>()),
    );
  });

  test('function does not exist', () {
    expect(
      () => parser.parse("fnc(asdf, asdf) + func(asdf, asdf)", context),
      throwsA(TypeMatcher<StringExpressionParseError>()),
    );
  });

  test('function has wrong number of parameters', () {
    expect(
      () => parser.parse("fnc(asdf, asdf)", context),
      throwsA(TypeMatcher<StringExpressionParseError>()),
    );
  });
}
