part of 'parser.dart';

/// options for the [StringExpressionParser]
class StringExpressionParserOptions {
  /// all characters that should be allowed for identifiers,
  /// like function names and variables
  ///
  /// no character should be:
  ///   1. a number
  ///   2. a character contained a operator from [operatorsWithPrecedence]
  ///   3. whitespace (spaces, line breaks, tabs)
  ///   4. repeated
  final String identifierCharacters;

  /// all characters that should be allowed for identifiers in a [Set],
  /// generated from [identifierCharacters]
  final Set<String> identifierCharactersSet;

  /// all characters that should be allowed for operators in a [Set],
  /// generated from [operatorsWithPrecedence]
  final Set<String> operatorCharactersSet;

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
  ///
  /// each operator should only be inside of [operatorsWithPrecedence] once,
  /// no character of any operator should be:
  ///   1. a number
  ///   2. a character which is contained in identifier characters
  ///   3. whitespace (spaces, line breaks, tabs)
  ///   4. no longer than one character
  final List<Set<String>> operatorsWithPrecedence;

  /// the implicit operator that should be used, such as (a)(b) or func(a)(b).
  ///
  /// if null is given as the [implicitOperator],
  /// then implicit operators are disabled
  ///
  /// the [implicitOperator] should be contained
  /// inside of the [operatorsWithPrecedence]
  final String? implicitOperator; // TODO: implicit operators not yet supported

  /// the operator that is used for negating, the default is '-'
  ///
  /// the [implicitOperator] should be contained
  /// inside of the [operatorsWithPrecedence]
  final String negationOperator;

  StringExpressionParserOptions({
    this.identifierCharacters = defaultIdentifierCharacters,
    this.operatorsWithPrecedence = defaultOperatorsWithPrecedence,
    this.implicitOperator = "*",
    this.negationOperator = "-",
  })  : identifierCharactersSet = <String>{}
          ..addAll(identifierCharacters.split("")),
        operatorCharactersSet =
            _twoDimensionalStringListToCharSet(operatorsWithPrecedence);

  static const defaultIdentifierCharacters =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const defaultOperatorsWithPrecedence = [
    {"^"},
    {"*", "/"},
    {"+", "-"},
  ];

  /// converts a two dimensional string list into a [String],
  /// where each character of the string list is only allowed to be contained once
  static Set<String> _twoDimensionalStringListToCharSet(List<Set<String>> ls) {
    final chars = <String>{};
    for (var s in ls) {
      chars.addAll(s);
    }
    return chars;
  }
}
