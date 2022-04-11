import "package:math_expressions/math_expressions.dart" hide MathFunction;
import "package:f_plot/domain/math_function.dart";
import "errors.dart";

enum _StatementParseStep {
  empty,
  identifier,
  afterIdentifier,
  afterOpeningBracket,
  afterClosingBracket,
  afterEquals,
}

enum _ArgumentsParseStep {
  empty,
  argument,
  afterArgument,
}

class _RawFunction {
  String name = "";
  List<String> arguments = [""];
  String body = "";

  List<String> get argumentsWithoutLastEmpty => arguments
      .where((argument) => argument.isNotEmpty)
      .toList(growable: false);
}

class PlotfileParser {
  final String plotFile;

  PlotfileParser(this.plotFile);

  List<String> getPlotFileLines() =>
      plotFile.split("\n").map((line) => line.trim()).toList(growable: false);

  static final _identifierRegexp = RegExp("[A-Za-z]");

  List<MathFunction> parse() {
    final lines = getPlotFileLines();
    final functions = <_RawFunction>[];
    var function = _RawFunction();
    var parseStep = _StatementParseStep.empty;
    var argumentParseStep = _ArgumentsParseStep.empty;
    line:
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      if (line.isEmpty && parseStep != _StatementParseStep.empty) {
        if (parseStep != _StatementParseStep.afterEquals) {
          throw ParseError(
            lineIndex,
            null,
            "must close function definition correctly, "
            "before leaving an empty line for the next function definition, "
            "ignore empty lines, by inserting a comment into the line '#'",
          );
        }
        functions.add(function);
        function = _RawFunction();
        parseStep = _StatementParseStep.empty;
        continue line;
      } else if (parseStep == _StatementParseStep.identifier) {
        parseStep == _StatementParseStep.afterIdentifier;
      } else if (parseStep == _StatementParseStep.afterOpeningBracket &&
          argumentParseStep == _ArgumentsParseStep.argument) {
        argumentParseStep = _ArgumentsParseStep.afterArgument;
      } else if (parseStep == _StatementParseStep.afterEquals) {
        function.body += " ";
      }
      for (var charIndex = 0; charIndex < line.length; charIndex++) {
        final char = line[charIndex];
        if (char == "#") {
          continue line;
        } else {
          switch (parseStep) {
            case _StatementParseStep.empty:
              if (_identifierRegexp.hasMatch(char)) {
                function.name += char;
                parseStep = _StatementParseStep.identifier;
                break;
              } else {
                throw ParseError(
                  lineIndex,
                  charIndex,
                  "expected begin of function identifier, "
                  "a function identifier can only contain "
                  "uppercase and lowercase letters",
                );
              }
            case _StatementParseStep.identifier:
              if (_identifierRegexp.hasMatch(char)) {
                function.name += char;
              } else if (char == " ") {
                parseStep = _StatementParseStep.afterIdentifier;
              } else if (char == "(") {
                parseStep = _StatementParseStep.afterOpeningBracket;
              } else {
                throw ParseError(
                  lineIndex,
                  charIndex,
                  "unexpected character $char, expected an identifier, "
                  "which are only allowed to contain letters "
                  "in upper and lower case",
                );
              }
              break;
            case _StatementParseStep.afterIdentifier:
              if (char == "(") {
                parseStep = _StatementParseStep.afterOpeningBracket;
                argumentParseStep = _ArgumentsParseStep.empty;
              } else if (char != " ") {
                throw ParseError(
                  lineIndex,
                  charIndex,
                  "expected opening bracket '(' to specify arguments "
                  "for function ${function.name}, got $char instead",
                );
              }
              break;
            case _StatementParseStep.afterOpeningBracket:
              switch (argumentParseStep) {
                case _ArgumentsParseStep.empty:
                  if (_identifierRegexp.hasMatch(char)) {
                    function.arguments.last += char;
                    argumentParseStep = _ArgumentsParseStep.argument;
                  } else if (char == ")") {
                    throw ParseError(
                      lineIndex,
                      charIndex,
                      "cannot close function arguments, "
                      "after a comma or without any arguments",
                    );
                  } else if (char != " ") {
                    throw ParseError(
                      lineIndex,
                      charIndex,
                      "expected a function argument name here, "
                      "which are only allowed to contain letters"
                      " in upper and lower case",
                    );
                  }
                  break;
                case _ArgumentsParseStep.argument:
                  if (_identifierRegexp.hasMatch(char)) {
                    function.arguments.last += char;
                  } else if (char == " ") {
                    argumentParseStep = _ArgumentsParseStep.afterArgument;
                  } else if (char == ",") {
                    argumentParseStep = _ArgumentsParseStep.empty;
                    function.arguments.add("");
                  } else if (char == ")") {
                    parseStep = _StatementParseStep.afterClosingBracket;
                  } else {
                    throw ParseError(
                      lineIndex,
                      charIndex,
                      "a function argument name can only contain letters"
                      " in upper and lower case",
                    );
                  }
                  break;
                case _ArgumentsParseStep.afterArgument:
                  if (_identifierRegexp.hasMatch(char)) {
                    throw ParseError(
                      lineIndex,
                      charIndex,
                      "separate function arguments with a comma (',')",
                    );
                  } else if (char == ",") {
                    argumentParseStep = _ArgumentsParseStep.empty;
                    function.arguments.add("");
                  } else if (char == ")") {
                    parseStep = _StatementParseStep.afterClosingBracket;
                  } else if (char != " ") {
                    throw ParseError(
                      lineIndex,
                      charIndex,
                      "did not expect the character '$char', "
                      "separate function arguments with a comma (',')",
                    );
                  }
                  break;
              }
              break;
            case _StatementParseStep.afterClosingBracket:
              if (char == "=") {
                parseStep = _StatementParseStep.afterEquals;
              } else if (char != " ") {
                throw ParseError(
                  lineIndex,
                  charIndex,
                  "expected equals ('=') before the function body",
                );
              }
              break;
            case _StatementParseStep.afterEquals:
              function.body += char;
              break;
          }
        }
      }
    }
    return functions
        .map(
          (rawFunction) => MathFunction(
            name: rawFunction.name,
            arguments: rawFunction.argumentsWithoutLastEmpty,
            body: Parser().parse(rawFunction.body),
          ),
        )
        .toList(growable: false);
  }
}
