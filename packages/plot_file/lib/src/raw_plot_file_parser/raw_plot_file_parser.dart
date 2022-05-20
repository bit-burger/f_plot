import 'package:expressions/expressions.dart';

part "raw_declarations.dart";

class RawPlotFileParser {
  final StringExpressionParser stringExpressionParser;
  final List<RawDeclaration> declarations = [];
  final List<StringExpressionParseError> parseErrors = [];

  RawPlotFileParser({
    required this.stringExpressionParser,
  });

  bool identifierExists(String identifier) {
    return declarations.any(
      (declaration) => declaration.identifier == identifier,
    );
  }

  List<String> getVariableParameters(String s, int begin, int end) {
    final parameters = <String>[];
    final rawParameters = s.substring(begin, end).split(",");
    var i = begin;
    if (rawParameters.isEmpty) {
      throw StringExpressionParseError(
          "a function declaration needs at least one parameter, "
          "for multiple parameters, separate with a comma (',')",
          begin - 1,
          end + 1);
    }
    for (final rawParameter in rawParameters) {
      final rawParameterBegin = i;
      while ("\n\t ".contains(s[i])) {
        i++;
      }
      final parameter = rawParameter.trim();
      if (parameter.isEmpty) {
        throw StringExpressionParseError("parameter identifier expected",
            rawParameterBegin, rawParameterBegin + rawParameter.length);
      } else if (parameters.contains(parameter)) {
        throw StringExpressionParseError(
          "each parameter name needs to be unique",
          rawParameterBegin,
          rawParameterBegin + rawParameter.length,
        );
      }
      stringExpressionParser.checkIdentifier(parameter, 0, parameter.length);
      parameters.add(parameter);
      i += rawParameter.length + 1;
    }
    return parameters;
  }

  void parseDeclaration(
    String s,
    int begin,
    int end,
  ) {
    while (s[end - 1] == " " || s[end - 1] == "\t") {
      end--;
    }
    var identifierEnd = begin;
    for (var i = begin; i < end; i++) {
      if ("\n\t =(".contains(s[i])) {
        break;
      }
      identifierEnd++;
    }
    if (begin == identifierEnd) {
      throw StringExpressionParseError("identifier expected", begin, end);
    }
    stringExpressionParser.checkIdentifier(s, begin, identifierEnd);
    var nextBegin = identifierEnd;
    for (var i = identifierEnd; i < end; i++) {
      if (!"\n\t ".contains(s[i])) {
        break;
      }
      nextBegin++;
    }
    if (nextBegin == end || (s[nextBegin] != "=" && s[nextBegin] != "(")) {
      throw StringExpressionParseError(
          "expected opening bracket ('(') "
          "or equals sign ('='), "
          "for either a function or variable declaration",
          nextBegin == end ? end - 1 : nextBegin);
    }
    late final RawDeclaration declaration;
    final identifier = s.substring(begin, identifierEnd);
    if (identifierExists(identifier)) {
      throw StringExpressionParseError(
          "identifier '$identifier' already exists", begin, identifierEnd);
    }
    if (s[nextBegin] == "(") {
      var closingBracket = nextBegin + 1;
      for (var i = nextBegin + 1; i < end; i++) {
        if (s[i] == ")") break;
        closingBracket++;
      }
      if (closingBracket == end) {
        throw StringExpressionParseError(
            "expected closing bracket, "
            "to close parameters definition of function definition",
            end - 1);
      }
      final parameters =
          getVariableParameters(s, nextBegin + 1, closingBracket);
      declaration = RawFunctionDeclaration(
        begin,
        identifierEnd,
        identifier,
        nextBegin + 1,
        closingBracket,
        parameters,
      );
      nextBegin = closingBracket + 1;
      for (var i = nextBegin; i < end; i++) {
        if (!"\n\t ".contains(s[i])) {
          break;
        }
        nextBegin++;
      }
      if (nextBegin == end || s[nextBegin] != "=") {
        throw StringExpressionParseError(
            "equals sign ('=') expected for function declaration",
            nextBegin == end ? end - 1 : nextBegin);
      }
    } else {
      declaration = RawVariableDeclaration(begin, identifierEnd, identifier);
    }
    if (nextBegin + 1 == end) {
      throw StringExpressionParseError(
          "expected the value of declaration after equals sign ('=')",
          nextBegin);
    }
    var bodyBegin = nextBegin + 1;
    for (var i = nextBegin + 1; i < end; i++) {
      if (!"\n\t ".contains(s[i])) break;
      bodyBegin++;
    }
    for (var i = bodyBegin; i < end; i++) {
      if (s[i] == "=") {
        throw StringExpressionParseError(
            "assignment only allowed on a new declaration", i);
      }
    }
    declaration.bodyStart = bodyBegin;
    declaration.bodyEnd = end;
    declaration.fillBody(s);
    declarations.add(declaration);
  }

  void parsePlotFile(String s) {
    var i = 0;
    while (i < s.length) {
      final char = s[i];
      if (char != "\n" && char != " " && char != "\n") {
        if (char == "#") {
          while (i < s.length && s[i] != "\n") {
            i++;
          }
        } else {
          final parseDeclarationBegin = i;
          var isError = false;
          var lineBreak = false;
          var lastLineBreak = -1;
          declarations: while (i < s.length) {
            final char = s[i];
            if (lineBreak) {
              if (char == "\n" || char == "#") {
                break;
              } else {
                while (s[i] == "\t" || s[i] == " ") {
                  i++;
                  if (i == s.length) {
                    break declarations;
                  }
                }
                if (s[i] == "#" || s[i] == "\n") {
                  if (s[i] == "#") {
                    i--;
                  }
                  break;
                }
                lineBreak = false;
              }
            }
            if (isError) {
              if (char == "\n") {
                lineBreak = true;
                lastLineBreak = i;
              }
            } else {
              if (char == "#") {
                parseErrors.add(StringExpressionParseError(
                    "cannot start comment inside of a declaration", i));
                isError = true;
              } else if (char == "\n") {
                lineBreak = true;
                lastLineBreak = i;
              }
            }
            i++;
          }
          if (!isError) {
            if (!lineBreak) {
              lastLineBreak = s.length;
            }
            try {
              parseDeclaration(s, parseDeclarationBegin, lastLineBreak);
            } on StringExpressionParseError catch (e) {
              parseErrors.add(e);
            }
          }
        }
      }
      i++;
    }
  }
}
