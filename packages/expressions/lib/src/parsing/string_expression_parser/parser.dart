import '../../expressions/expression.dart';
import '../parser.dart';

part 'error.dart';
part 'options.dart';

/// implements [ExpressionParser] to parse strings to expressions.
///
/// throws [StringExpressionParseError] on an error
class StringExpressionParser implements ExpressionParser<String> {
  final StringExpressionParserOptions _options;

  StringExpressionParser({StringExpressionParserOptions? options})
      : _options = options ?? StringExpressionParserOptions();

  /// throws an error if a variable identifier is used,
  /// that is not in the [SetParserContext] (if there is a context)
  void checkVariable(
    String s,
    int begin,
    int end,
    ParserContext? c,
    Iterable<String> tempAllowedVariables,
  ) {
    final v = s.substring(begin, end);
    if (tempAllowedVariables.contains(v)) {
      return;
    }
    if (!(c?.variableAllowed(v) ?? true)) {
      throw StringExpressionParseError("variable '$v' unknown", begin, end);
    }
  }

  /// throws an error if a function identifier is used,
  /// that is not in the [SetParserContext] (if there is a context)
  void checkFunctionIdentifier(
    String s,
    int begin,
    int nameEnd,
    int functionCallEnd,
    int functionParameterCount,
    ParserContext? c,
  ) {
    final f = s.substring(begin, nameEnd);
    if (c != null) {
      final allowedParameterCount = c.allowedFunctionParameterCount(f);
      if (allowedParameterCount == null) {
        throw StringExpressionParseError(
            "function '$f' unknown", begin, nameEnd);
      } else if (functionParameterCount != allowedParameterCount) {
        throw StringExpressionParseError(
          "function '$f' should be called with "
          "$allowedParameterCount parameter"
          "${allowedParameterCount > 1 ? "s" : ""}, it was instead called with "
          "$functionParameterCount parameter"
          "${functionParameterCount > 1 ? "s" : ""}",
          begin,
          functionCallEnd,
        );
      }
    }
  }

  /// throws an error on a invalid identifier
  void checkIdentifier(String s, int begin, int end) {
    for (var i = begin; i < end; i++) {
      if (!isIdentifierChar(s[i])) {
        throw StringExpressionParseError(
            "an identifier cannot contain '${s[i]}'", begin);
      }
    }
  }

  /// throws an error on a non valid decimal number
  void checkNumber(String s, int begin, int end) {
    var afterDecimalSeparator = false;
    for (var i = begin; i < end; i++) {
      if (s[i] == ".") {
        if (afterDecimalSeparator) {
          throw StringExpressionParseError(
              "one number cannot contain 2 decimal separators", i);
        }
        afterDecimalSeparator = true;
      } else if (!isNumberChar(s[i])) {
        throw StringExpressionParseError(
            "a decimal number cannot contain the character '${s[i]}'", i);
      }
    }
  }

  /// checks the given char, if it is a number
  bool isNumberChar(String char) {
    const numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    return numbers.contains(char);
  }

  /// checks the char if it is a char associated with operators
  bool isOperatorChar(String char) {
    return _options.operatorCharactersSet.contains(char);
  }

  /// checks the char if it is a valid identifier char
  bool isIdentifierChar(String char) {
    return _options.identifierCharactersSet.contains(char);
  }

  /// checks if the char is whitespace
  bool isWhitespaceChar(String char) {
    return char == " " || char == "\n" || char == "\t";
  }

  /// gives back the precedence of the given operator,
  /// the higher the int the lower the precedence.
  ///
  /// uses
  /// [StringExpressionParserOptions.defaultOperatorsWithPrecedence]
  /// to get the precedence from the operators given by [_options].
  ///
  /// will also throw error if the operator is not valid
  int getOperatorPrecedence(String s, int operatorIndex) {
    for (var precedence = 0;
        precedence < _options.operatorsWithPrecedence.length;
        precedence++) {
      final operatorsOfPrecedence =
          _options.operatorsWithPrecedence[precedence];
      if (operatorsOfPrecedence.contains(s[operatorIndex])) {
        return precedence;
      }
    }
    throw StringExpressionParseError(
        "operator '${s[operatorIndex]}' not valid", operatorIndex);
  }

  /// gives the list of expressions found inside of a function call.
  ///
  /// example: 'func(a,b,c)'
  /// [getFunctionArguments] would then be called with the range: 'a,b,c'
  /// and would return three [Variable] inside of the returning [List].
  ///
  /// can be called with white space in front and back
  List<Expression> getFunctionArguments(
    String s,
    int begin,
    int end,
    ParserContext? c,
    Iterable<String> tempAllowedVariables,
  ) {
    final b = begin, e = end;
    // remove whitespace
    while (isWhitespaceChar(s[begin])) {
      begin++;
    }
    while (isWhitespaceChar(s[end - 1])) {
      end--;
    }
    if (end == begin) {
      throw StringExpressionParseError(
          "At least one function argument has to be given", b - 1, e + 1);
    }
    if (s[begin] == ",") {
      throw StringExpressionParseError(
          "comma cannot be in front of function arguments", begin);
    }
    if (s[end - 1] == ",") {
      throw StringExpressionParseError(
          "comma cannot be in back of function arguments", begin);
    }
    var brackets = 0;
    final expressions = <Expression>[];
    var lastArgumentEnd = begin - 1; // index of last comma or before first arg
    for (var i = begin; i < end; i++) {
      if (brackets > 0) {
        if (s[i] == ")") {
          brackets--;
        }
      } else if (s[i] == "(") {
        brackets++;
      } else if (s[i] == ",") {
        expressions.add(
            operatorParse(s, lastArgumentEnd + 1, i, c, tempAllowedVariables));
        lastArgumentEnd = i;
      }
    }
    expressions.add(
        operatorParse(s, lastArgumentEnd + 1, end, c, tempAllowedVariables));
    return expressions;
  }

  /// parses a function call such as 'func(a,b,c)' to a [FunctionCall].
  ///
  /// should be called with no whitespace in front and back
  FunctionCall functionCallParse(
    String s,
    int begin,
    int end,
    ParserContext? c,
    Iterable<String> tempAllowedVariables,
  ) {
    var identifierEnd = -1;
    var bracketsBegin = -1;
    for (var i = begin; i < end; i++) {
      if (identifierEnd == -1) {
        if (isWhitespaceChar(s[i])) {
          identifierEnd = i;
        } else if (s[i] == "(") {
          identifierEnd = i;
          bracketsBegin = i;
          break;
        } else if (!isIdentifierChar(s[i])) {
          throw StringExpressionParseError(
              "an identifier cannot contain '${s[i]}'", i);
        }
      } else {
        if (s[i] == "(") {
          bracketsBegin = i;
          break;
        } else if (!isWhitespaceChar(s[i])) {
          throw StringExpressionParseError(
              "between the function name and its arguments list, "
              "which is in brackets, "
              "only whitespace is permitted",
              i);
        }
      }
    }
    checkIdentifier(s, begin, identifierEnd);
    final functionArguments = getFunctionArguments(
        s, bracketsBegin + 1, end - 1, c, tempAllowedVariables);
    checkFunctionIdentifier(
        s, begin, identifierEnd, end, functionArguments.length, c);
    return FunctionCall(s.substring(begin, identifierEnd), functionArguments);
  }

  /// Parses an expression after it is clear,
  /// that there are no operators in the current range and bracket level.
  ///
  /// example 1: '23'.
  ///
  /// example 2: 'func(a+b,c)',
  /// (the operators here are nested inside of a lower bracket level).
  ///
  /// should be called with no whitespace in front or back
  Expression noOperatorParse(String s, int begin, int end, ParserContext? c,
      Iterable<String> tempAllowedVariables) {
    if (s[begin] == "(") {
      return operatorParse(s, begin + 1, end - 1, c, tempAllowedVariables);
    } else if (isIdentifierChar(s[begin])) {
      if (s[end - 1] == ")") {
        return functionCallParse(s, begin, end, c, tempAllowedVariables);
      }
      checkIdentifier(s, begin, end);
      checkVariable(s, begin, end, c, tempAllowedVariables);
      return Variable(s.substring(begin, end));
    } else if (isNumberChar(s[begin])) {
      checkNumber(s, begin, end);
      return Number(double.parse(s.substring(begin, end)));
    } else {
      throw StringExpressionParseError(
          "character '${s[begin]}' not expected here", begin);
    }
  }

  /// should be called with no whitespace in front or back
  ///
  /// looks for implicit operators such as a1 which would be interpreted as a*1
  Expression implicitOperatorParse(String s, int begin, int end,
      ParserContext? c, Iterable<String> tempAllowedVariables) {
    // TODO: not implemented, should probably be implemented by operatorParse
    //       (operator precedence doesn't make sense otherwise)
    return noOperatorParse(s, begin, end, c, tempAllowedVariables);
  }

  /// searches for the highest precedence operator and
  /// gives back an [OperatorCall],
  /// by parsing whats in front and in back of the found operator,
  /// by calling those ranges recursively.
  ///
  /// if, however, no operator has been found in the given range,
  /// [implicitOperatorParse] will be called.
  ///
  /// can be called with white space in front and back
  ///
  /// examples of precedence:
  ///   a+a+a => (a+a)+a
  ///   a+-a  => a+(-a)
  ///   -a^-a => -(a^(-a))
  Expression operatorParse(String s, int begin, int end, ParserContext? c,
      Iterable<String> tempAllowedVariables) {
    final e = end;
    // remove whitespace in back
    while (begin < end && isWhitespaceChar(s[end - 1])) {
      end--;
    }
    if (begin == end) {
      throw StringExpressionParseError(
          "expression in brackets expected", begin - 1, e + 1);
    }

    var braces = 0;
    var firstNonWhitespaceIndex = -1;
    var lowestPrecedenceOperatorIndex = -1;
    var lowestPrecedence = -1;
    var currentOperatorIndex = -1;
    var operatorOpen = false;

    for (var i = begin; i < end; i++) {
      final char = s[i];
      if (firstNonWhitespaceIndex == -1) {
        if (isWhitespaceChar(char)) {
          continue;
        } else {
          firstNonWhitespaceIndex = i;
        }
      }
      if (braces > 0) {
        if (char == ")") {
          braces--;
        } else if (char == "(") {
          braces++;
        }
        continue;
      } else {
        if (char == ")") {
          throw StringExpressionParseError("one closing bracket too much", i);
        } else if (char == "(") {
          braces++;
        }
      }
      if (!operatorOpen) {
        if (isOperatorChar(char)) {
          operatorOpen = true;
          currentOperatorIndex = i;
        }
      } else {
        if (isOperatorChar(char)) {
          if (char != _options.negationOperator) {
            throw StringExpressionParseError(
                "a second operand was expected, not another operator", i);
          }
        } else if (!isWhitespaceChar(char)) {
          final currentPrecedence =
              getOperatorPrecedence(s, currentOperatorIndex);
          if (currentPrecedence >= lowestPrecedence) {
            lowestPrecedenceOperatorIndex = currentOperatorIndex;
            lowestPrecedence = currentPrecedence;
          }
          operatorOpen = false;
        }
      }
    }
    if (operatorOpen) {
      throw StringExpressionParseError(
          "operator '${s[currentOperatorIndex]}' needs a right operand",
          currentOperatorIndex,
          end);
    }
    if (firstNonWhitespaceIndex == -1) {
      throw StringExpressionParseError("expression expected", begin, end);
    }
    if (braces > 0) {
      throw StringExpressionParseError("closing brace missing", end - 1);
    }
    if (lowestPrecedenceOperatorIndex == -1) {
      return implicitOperatorParse(
          s, firstNonWhitespaceIndex, end, c, tempAllowedVariables);
    }
    if (lowestPrecedenceOperatorIndex == firstNonWhitespaceIndex) {
      if (s[lowestPrecedenceOperatorIndex] == _options.negationOperator) {
        return NegateOperator(operatorParse(
            s, firstNonWhitespaceIndex + 1, end, c, tempAllowedVariables));
      } else {
        throw StringExpressionParseError(
            "expected operand before operator", lowestPrecedenceOperatorIndex);
      }
    }
    // TODO: optimise always calling operatorParse again
    final expression1 = operatorParse(
      s,
      firstNonWhitespaceIndex,
      lowestPrecedenceOperatorIndex,
      c,
      tempAllowedVariables,
    );
    final expression2 = operatorParse(
      s,
      lowestPrecedenceOperatorIndex + 1,
      end,
      c,
      tempAllowedVariables,
    );
    return OperatorCall(
      s[lowestPrecedenceOperatorIndex],
      expression1,
      expression2,
    );
  }

  @override
  Expression parse(
    String rawExpression, [
    ParserContext? c,
    Iterable<String> tempAllowedVariables = const {},
  ]) {
    return operatorParse(
      rawExpression,
      0,
      rawExpression.length,
      c,
      tempAllowedVariables,
    );
  }
}
