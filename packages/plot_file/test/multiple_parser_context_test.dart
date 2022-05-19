import 'package:expressions/expressions.dart';
import 'package:plot_file/src/multiple_parser_context.dart';
import 'package:test/test.dart';

String declarationsToString(
    List<RawDeclaration> declarations, String plotfile) {
  var s = "";
  for (final declaration in declarations) {
    final identifier = declaration.identifier;
    final arguments =
        declaration is RawFunctionDeclaration ? declaration.parameters : null;
    final body = plotfile.substring(declaration.bodyStart, declaration.bodyEnd);
    s +=
        "$identifier${arguments == null ? "" : "(${arguments.join(", ")})"} = $body\n";
  }
  return s.substring(0, s.length - 1);
}

void main() {
  final stringExpressionParser = StringExpressionParser();

  test('simple plot file parsing', () {
    final plotfile = """
    a  (   x  )=   34t
    #asdf
    x = 2 3 4

    fb  \n   (x) = 345""";
    final parser = MultipleParserContext(
      stringExpressionParser: stringExpressionParser,
    );
    parser.parsePlotFile(plotfile);

    expect(
      declarationsToString(parser.declarations, plotfile),
      """
a(x) = 34t
x = 2 3 4
fb(x) = 345""",
    );

    expect(parser.parseErrors, isEmpty);
  });

  group("errors", () {
    test('unfinished declaration', () {
      final plotfile = "a = ";
      final parser = MultipleParserContext(
        stringExpressionParser: stringExpressionParser,
      );
      parser.parsePlotFile(plotfile);

      expect(
        parser.parseErrors,
        isNotEmpty,
      );
    });

    test('parameter repeated', () {
      final plotfile = "f(a,a) = a";
      final parser = MultipleParserContext(
        stringExpressionParser: stringExpressionParser,
      );
      parser.parsePlotFile(plotfile);

      expect(
        parser.parseErrors,
        isNotEmpty,
      );
    });
  });
}
