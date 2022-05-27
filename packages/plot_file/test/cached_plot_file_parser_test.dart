import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:plot_file/plot_file.dart';
import 'package:test/test.dart';

void main() {
  group("valid plot files", () {
    test("one line plot file", () {
      final parser = CachedPlotFileParser(
        expressionParserOptions: StringExpressionParserOptions(),
      );
      final plotFile = """
       f(x) = pi * x
       
       x = f(2) + 1
      """;
      parser.parseAndCache(plotFile);
      expect(parser.errors, isEmpty);
      expect(parser.functions, {
        "f": CachedFunctionDeclaration(
          parameters: ["x"],
          body: Expression.fromString("$pi * x"),
        ),
      });
      expect(parser.variables, {
        "x": CachedVariableDeclaration(value: 2 * pi + 1),
      });
    });
  });

  group("invalid plot files", () {
    test("second plot file in caching is invalid, third removes a declaration",
        () {
      final parser = CachedPlotFileParser(
        expressionParserOptions: StringExpressionParserOptions(),
      );
      final firstPlotFile = """
       f(x) = pi * x
       
       x = f(2) + 1
      """;
      final secondPlotFile = """
       f(x) = pi * x * a
       
       x = f(2) + 1
      """;
      final thirdPlotFile = """
       f(x) = pi * x * x
      """;
      parser.parseAndCache(firstPlotFile);
      expect(parser.errors, isEmpty);

      parser.parseAndCache(secondPlotFile);
      expect(parser.errors, isNotEmpty);

      parser.parseAndCache(thirdPlotFile);
      expect(parser.errors, isEmpty);
      expect(parser.variables, isEmpty);
      expect(parser.functions, {
        "f": CachedFunctionDeclaration(
          parameters: ["x"],
          body: Expression.fromString("$pi * x * x"),
        ),
      });
    });
  });
}
