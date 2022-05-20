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
      expect(parser.functions, {
        "f": CachedFunctionDeclaration(
          parameters: ["x"],
          body: Expression.fromString("$pi * x"),
        ),
      });
      expect(parser.variables, {
        "x": CachedVariableDeclaration(value: 2 * pi + 1),
      });
      expect(parser.errors, isEmpty);
    });


  });

  group("invalid plot files", () {
    test("second plot file in caching is invalid", () {
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
      parser.parseAndCache(firstPlotFile);
      parser.parseAndCache(secondPlotFile);

      expect(parser.errors, isNotEmpty);
    });
  });

  group("caching of plot files", () {});
}
