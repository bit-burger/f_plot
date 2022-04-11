import 'package:expressions/src/errors.dart';
import 'package:expressions/src/expression.dart';
import 'package:expressions/src/parser.dart';

class RegularStringExpressionParser extends ExpressionParser<String> {
  final RegularStringExpressionParserOptions _options;

  RegularStringExpressionParser({RegularStringExpressionParserOptions? options})
      : _options = options ?? RegularStringExpressionParserOptions();

  /// throws an error on a invalid identifier
  void checkIdentifier(String s, int begin, int end) {
    for (var i = begin; i < end; i++) {
      if (!isIdentifierChar(s[i])) {
        throw ParseError("an identifier cannot contain '${s[i]}'", begin);
      }
    }
  }

  /// throws an error on a non valid decimal number
  void checkNumber(String s, int begin, int end) {
    var afterDecimalSeparator = false;
    for (var i = begin; i < end; i++) {
      if (s[i] == ".") {
        if (afterDecimalSeparator) {
          throw ParseError("one number cannot contain 2 decimal separators", i);
        }
        afterDecimalSeparator = true;
      } else if (!isNumberChar(s[i])) {
        throw ParseError(
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
    return _options.operatorCharacters.contains(char);
  }

  /// checks the char if it is a valid identifier char
  bool isIdentifierChar(String char) {
    return _options.identifierCharacters.contains(char);
  }

  /// checks if the char is whitespace
  bool isWhitespaceChar(String char) {
    return char == " " || char == "\n" || char == "\t";
  }

  /// gives back the precedence of the given operator,
  /// the higher the int the lower the precedence.
  ///
  /// uses
  /// [RegularStringExpressionParserOptions.standardOperatorsWithPrecedence]
  /// to get the precedence from the operators given by [_options].
  ///
  /// will also throw error if the operator is not valid
  int getOperatorPrecedence(int begin, String operator) {
    for (var precedence = 0;
        precedence < _options.operatorsWithPrecedence.length;
        precedence++) {
      final operatorsOfPrecedence =
          _options.operatorsWithPrecedence[precedence];
      if (operatorsOfPrecedence.contains(operator)) {
        return precedence;
      }
    }
    throw ParseError(
        "operator '$operator' not valid", begin, begin + operator.length);
  }

  /// gives the list of expressions found inside of a function call.
  ///
  /// example: 'func(a,b,c)'
  /// [getFunctionArguments] would then be called with the range: 'a,b,c'
  /// and would return three [VariableReference] inside of the returning [List].
  ///
  /// can be called with white space in front and back
  List<Expression> getFunctionArguments(String s, int begin, int end) {
    // remove whitespace
    while (isWhitespaceChar(s[begin])) {
      begin++;
    }
    while (isWhitespaceChar(s[end - 1])) {
      end--;
    }
    if (s[begin] == ",") {
      throw ParseError("comma cannot be in front of function arguments", begin);
    }
    if (s[end - 1] == ",") {
      throw ParseError("comma cannot be in back of function arguments", begin);
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
        expressions.add(operatorParse(s, lastArgumentEnd + 1, i));
        lastArgumentEnd = i;
      }
    }
    expressions.add(operatorParse(s, lastArgumentEnd + 1, end));
    return expressions;
  }

  /// parses a function call such as 'func(a,b,c)' to a [FunctionCall].
  ///
  /// should be called with no whitespace in front and back
  FunctionCall functionCallParse(String s, int begin, int end) {
    var identifierEnd = -1;
    var bracketsBegin = -1;
    for (var i = begin; i < end; i++) {
      final c = s[i]; //TODO: DEBUG REMOVE
      if (identifierEnd == -1) {
        if (isWhitespaceChar(s[i])) {
          identifierEnd = i;
        } else if (s[i] == "(") {
          identifierEnd = i;
          bracketsBegin = i;
          break;
        } else if (!isIdentifierChar(s[i])) {
          throw ParseError("an identifier cannot contain '${s[i]}'", i);
        }
      } else {
        if (s[i] == "(") {
          bracketsBegin = i;
          break;
        } else if (!isWhitespaceChar(s[i])) {
          throw ParseError(
              "between the function name and its arguments list, "
              "which is in brackets, "
              "only whitespace is permitted",
              i);
        }
      }
    }
    checkIdentifier(s, begin, identifierEnd);
    final functionArguments =
        getFunctionArguments(s, bracketsBegin + 1, end - 1);
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
  /// should be called with no whitespace in front
  Expression noOperatorParse(String s, int begin, int end) {
    // remove whitespace in back
    while (isWhitespaceChar(s[end - 1])) {
      end--;
    }
    assert(begin < end);
    if (s[begin] == "(") {
      return operatorParse(s, begin + 1, end - 1);
    } else if (isIdentifierChar(s[begin])) {
      if (s[end - 1] == ")") {
        return functionCallParse(s, begin, end);
      }
      checkIdentifier(s, begin, end);
      return VariableReference(s.substring(begin, end));
    } else if (isNumberChar(s[begin])) {
      checkNumber(s, begin, end);
      return Number(double.parse(s.substring(begin, end)));
    } else {
      throw ParseError("character '${s[begin]}' not expected here", begin);
    }
  }

  /// should be called with no whitespace in front
  Expression implicitOperatorParse(String s, int begin, int end) {
    // TODO: not implemented, should probably be implemented by operatorParse
    //       (operator precedence doesn't make sense otherwise)
    return noOperatorParse(s, begin, end);
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
  Expression operatorParse(String s, int begin, int end) {
    var braces = 0;
    var firstNonWhitespaceIndex = -1;
    var lowestPrecedenceOperatorIndex = -1, lowestPrecedenceOperator = "";
    var lowestPrecedence = -1;
    var currentOperatorIndex = -1, currentOperator = "";
    var isOperator = false;
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
        } else if(char == "(") {
          braces++;
        }
        continue;
      } else if (char == ")") {
        throw ParseError("one closing bracket too much", i);
      }
      if (isOperator) {
        if (isOperatorChar(char)) {
          currentOperator += char;
        } else {
          if (char == "(") {
            braces++;
          }
          final currentPrecedence = getOperatorPrecedence(i, currentOperator);
          if (currentPrecedence > lowestPrecedence) {
            lowestPrecedenceOperatorIndex = currentOperatorIndex;
            lowestPrecedenceOperator = currentOperator;
            lowestPrecedence = currentPrecedence;
          }
          currentOperator = "";
          isOperator = false;
        }
      } else {
        if (isOperatorChar(char)) {
          if (i == firstNonWhitespaceIndex) {
            throw ParseError("expected expression before operator", i);
          }
          isOperator = true;
          currentOperatorIndex = i;
          currentOperator = char;
        } else if (char == "(") {
          braces++;
        }
      }
    }
    if (firstNonWhitespaceIndex == -1) {
      throw ParseError("expression expected", begin, end);
    }
    if (braces > 0) {
      throw ParseError("closing brace missing", end - 1);
    }
    if (lowestPrecedenceOperatorIndex == -1) {
      return implicitOperatorParse(s, firstNonWhitespaceIndex, end);
    }
    // TODO: optimise always calling operatorParse again
    final expression1 = operatorParse(
      s,
      firstNonWhitespaceIndex,
      lowestPrecedenceOperatorIndex,
    );
    final expression2 = operatorParse(
      s,
      lowestPrecedenceOperatorIndex + lowestPrecedenceOperator.length,
      end,
    );
    return OperatorCall(lowestPrecedenceOperator, expression1, expression2);
  }

  @override
  Expression parse(String rawExpression) {
    return operatorParse(rawExpression, 0, rawExpression.length);
  }
}

/// converts a two dimensional string list into a [String],
/// where each character of the string list is only allowed to be contained once
String _twoDimensionalStringListToUniqueChars(List<Set<String>> strings) {
  final chars = <String>{};
  for (var s in strings) {
    chars.addAll(s);
  }
  return chars.join();
}

/// options for the [RegularStringExpressionParser]
class RegularStringExpressionParserOptions {
  /// all characters that should be allowed for identifiers,
  /// like function names and variables
  final String identifierCharacters;

  /// all characters that should be allowed for operators,
  /// generated from [operatorsWithPrecedence]
  final String operatorCharacters;

  /// all operators, generated from [operatorsWithPrecedence]
  final List<String> operators;

  /// all operators that are allowed.
  ///
  /// each string [Set] inside of the [operatorsWithPrecedence],
  /// represents one precedence,
  /// meaning that those operators inside of that [Set],
  /// are given the same precedence.
  ///
  /// the last string [Set] inside of [operatorsWithPrecedence],
  /// has the lowest precedence.
  ///
  /// per default this is the last [Set]: {'+', '-'} and
  /// the first string [Set] (which therefore has the highest precedence),
  /// is per default this: {'^'}
  final List<Set<String>> operatorsWithPrecedence;

  /// the implicit operator that should be used, such as (a)(b) or func(a)(b).
  ///
  /// if null is given as the [implicitOperator],
  /// then implicit operators are disabled
  final String? implicitOperator; // TODO: implicit operators not yet supported

  RegularStringExpressionParserOptions({
    this.identifierCharacters = standardIdentifierCharacters,
    this.operatorsWithPrecedence = standardOperatorsWithPrecedence,
    this.implicitOperator = "*",
  })  : operators = operatorsWithPrecedence
            .map((operators) => operators.join())
            .toList(growable: false),
        operatorCharacters =
            _twoDimensionalStringListToUniqueChars(operatorsWithPrecedence);

  static const standardIdentifierCharacters =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const standardOperatorsWithPrecedence = [
    {"^"},
    {"*", "/"},
    {"+", "-"},
  ];
}
