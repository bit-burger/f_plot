import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:math_code_field/src/code_field.dart';
import 'style.dart';
import 'code_error.dart';

/// the [TextEditingController] of the [MathCodeField]
class MathCodeEditingController extends TextEditingController {
  static const operators = "+-*/^=";
  static const identifierLetters =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKMNOPQRSTUVWXYZ";
  static const whiteSpace = " \t\n";
  static const alphaNumeric = identifierLetters + validDigits;
  static const validDigits = "1234567890.";
  static const separators = "$whiteSpace$operators)(,";

  List<CodeError> _currentErrors = [];

  void setErrors(List<CodeError> errors) {
    _currentErrors = errors;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final themeData =
        MathCodeFieldTheme.of(context) ?? MathCodeFieldThemeData();
    final spans = _spansForText(text, themeData);
    if (spans.isNotEmpty) {
      _replaceSpansWithErrors(spans, _currentErrors, themeData.errorTextStyle);
    }
    return TextSpan(children: spans, style: style);
  }

  /// apply the [CodeError]s to the given spans.
  ///
  /// uses the [MathCodeFieldThemeData.errorTextStyle]
  /// for the styling of the errors
  void _replaceSpansWithErrors(
    List<TextSpan> spans,
    List<CodeError> errors,
    TextStyle errorStyle,
  ) {
    for (final error in errors) {
      _replaceSpansWithError(spans, error, errorStyle);
    }
  }

  void _replaceSpansWithError(
    List<TextSpan> spans,
    CodeError error,
    TextStyle errorStyle,
  ) {
    var firstSpan = 0;
    var currentCharacter = (spans[0].text?.length ?? 0) - 1;
    while (currentCharacter < error.begin) {
      firstSpan++;
      currentCharacter += spans[firstSpan].text?.length ?? 0;
    }
    final firstCharacterFirstSpan = ((spans[firstSpan].text?.length ?? 0) - 1) -
        (currentCharacter - error.begin);
    var lastSpan = firstSpan;
    while (currentCharacter < error.realEnd - 1) {
      lastSpan++;
      currentCharacter += spans[lastSpan].text?.length ?? 0;
    }
    final lastCharacterLastSpan = ((spans[lastSpan].text?.length ?? 0) - 1) -
        (currentCharacter - (error.realEnd - 1));
    assert(firstSpan < lastSpan ||
        (firstSpan == lastSpan &&
            firstCharacterFirstSpan <= lastCharacterLastSpan));

    _replaceRangeOfSpansWithError(
      spans,
      firstSpan,
      firstCharacterFirstSpan,
      lastSpan,
      lastCharacterLastSpan,
      errorStyle,
      error.message,
    );
  }

  void _replaceRangeOfSpansWithError(
    List<TextSpan> spans,
    int firstSpan,
    int firstCharacterFirstSpan,
    int lastSpan,
    int lastCharacterLastSpan,
    TextStyle errorStyle,
    String? errorMessage,
  ) {
    if (firstSpan == lastSpan) {
      _replacePartOfSpanWithError(
        spans,
        firstSpan,
        firstCharacterFirstSpan,
        lastCharacterLastSpan,
        errorStyle,
        errorMessage,
      );
      return;
    }
    for (var i = firstSpan; i <= lastSpan; i++) {
      late final int firstCharacterOfSpan;
      if (i == 0) {
        firstCharacterOfSpan = firstCharacterFirstSpan;
      } else {
        firstCharacterOfSpan = 0;
      }
      late final int lastCharacterOfSpan;
      if (i == lastSpan) {
        lastCharacterOfSpan = lastCharacterLastSpan;
      } else {
        lastCharacterOfSpan =
            (spans[i].text?.length ?? 0) - 1; // span has already been removed
      }
      assert(firstCharacterOfSpan <= lastCharacterOfSpan);
      _replacePartOfSpanWithError(
        spans,
        i,
        firstCharacterOfSpan,
        lastCharacterOfSpan,
        errorStyle,
        errorMessage,
      );
    }
  }

  void _replacePartOfSpanWithError(
    List<TextSpan> spans,
    int spanIndex,
    int firstCharacter,
    int lastCharacter,
    TextStyle errorStyle,
    String? errorMessage,
  ) {
    final span = spans.removeAt(spanIndex);
    final text = span.text!;
    final style = span.style;
    final mergedErrorStyle =
        style == null ? errorStyle : errorStyle.merge(style);
    try {
      final replacementSpans = [
        if (firstCharacter != 0)
          TextSpan(
            text: text.substring(0, firstCharacter),
            style: style,
          ),
        TextSpan(
          text: text.substring(firstCharacter, lastCharacter + 1),
          style: mergedErrorStyle,
        ),
        if (lastCharacter != text.length - 1)
          TextSpan(
            text: text.substring(lastCharacter + 1),
            style: style,
          ),
      ];

      spans.insert(
        spanIndex,
        TextSpan(children: replacementSpans),
      );
    } catch (e) {
      print("asdf");
    }
  }

  List<TextSpan> _spansForText(
    String text,
    MathCodeFieldThemeData themeData,
  ) {
    final textSpans = <TextSpan>[];
    var lineBreaks = 0;
    var begin = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == "\n") {
        lineBreaks++;
        if (lineBreaks == 2) {
          textSpans
              .addAll(_spansInDeclarations(text, begin, i + 1, 0, themeData));

          lineBreaks = 0;
          begin = i + 1;
        }
      } else if (char != " " && char != "\t") {
        lineBreaks = 0;
      }
    }
    if (begin < text.length) {
      textSpans
          .addAll(_spansInDeclarations(text, begin, text.length, 0, themeData));
    }
    return textSpans;
  }

  List<TextSpan> _spansInDeclarations(
    String text,
    int begin,
    int end,
    int bracketDepth,
    MathCodeFieldThemeData themeData,
  ) {
    final children = <TextSpan>[/*const TextSpan(text: "")*/];
    var separated =
        true; // is true if a bracket, whitespace, comma or operator was the last character
    var nonSeparatedIndex = -1;
    var nonSeperatedIsNumber =
        false; // if something non separated begins with a-z or A-Z
    var nonSeperatedIsError = false;
    // else it is a number
    var brackets = 0;
    var bracketsBeginIndex = -1;
    for (var i = begin; i < end; i++) {
      final char = text[i];
      if (brackets > 0) {
        if (char == ")") {
          brackets = max(0, brackets - 1);
          if (brackets == 0) {
            children.addAll(
              _spansForBracket(
                  text, bracketsBeginIndex, i + 1, bracketDepth + 1, themeData),
            );
            separated = true;
          }
        } else if (char == "(") {
          brackets++;
        }
      } else {
        if (!separated) {
          if (!separators.contains(char)) {
            if (!nonSeperatedIsError) {
              if (nonSeperatedIsNumber) {
                if (!validDigits.contains(char)) {
                  nonSeperatedIsError = true;
                }
              } else {
                if (!alphaNumeric.contains(char)) {
                  nonSeperatedIsError = true;
                }
              }
            }
            continue;
          } else {
            if (nonSeperatedIsError) {
              children
                  .add(_spanForError(text, nonSeparatedIndex, i, themeData));
            } else if (nonSeperatedIsNumber) {
              children
                  .add(_spanForNumber(text, nonSeparatedIndex, i, themeData));
            } else {
              children
                  .add(_spanForVariable(text, nonSeparatedIndex, i, themeData));
            }
            separated = true;
          }
        } else {
          if (!separators.contains(char)) {
            if (identifierLetters.contains(char)) {
              nonSeperatedIsNumber = false;
              nonSeperatedIsError = false;
            } else if (validDigits.contains(char)) {
              nonSeperatedIsNumber = true;
              nonSeperatedIsError = false;
            } else {
              nonSeperatedIsError = true;
            }
            nonSeparatedIndex = i;
            separated = false;
            continue;
          }
        }
        if (char == ")") {
          children.add(
            TextSpan(
              text: char,
              style: TextStyle(color: themeData.errorColor),
            ),
          );
        } else if (char == "(") {
          brackets++;
          bracketsBeginIndex = i;
        } else if (operators.contains(char)) {
          children.add(_spanForOperator(text, i, themeData));
        } else if (whiteSpace.contains(char) || char == ",") {
          children.add(TextSpan(text: char));
        }
      }
    }
    if (brackets > 0) {
      children.addAll(
        _spansForBracket(
            text, bracketsBeginIndex, end, bracketDepth + 1, themeData, true),
      );
    } else if (!separated) {
      if (nonSeperatedIsError) {
        children.add(_spanForError(text, nonSeparatedIndex, end, themeData));
      } else if (nonSeperatedIsNumber) {
        children.add(_spanForNumber(text, nonSeparatedIndex, end, themeData));
      } else {
        children.add(_spanForVariable(text, nonSeparatedIndex, end, themeData));
      }
    }
    return children;
  }

  List<TextSpan> _spansForBracket(
    String text,
    int begin,
    int end,
    int bracketDepth,
    MathCodeFieldThemeData themeData, [
    bool lastBracketMissing = false,
  ]) {
    final bracketStyle = TextStyle(
      color: themeData.bracketColorForDepth(bracketDepth),
    );
    final spans = _spansInDeclarations(
      text,
      begin + 1,
      lastBracketMissing ? end : end - 1,
      bracketDepth,
      themeData,
    );
    return [
      TextSpan(
        text: "(",
        style: lastBracketMissing
            ? TextStyle(color: themeData.errorColor)
            : bracketStyle,
      ),
      TextSpan(children: spans),
      if (!lastBracketMissing)
        TextSpan(
          text: ")",
          style: bracketStyle,
        ),
    ];
  }

  TextSpan _spanForVariable(
    String text,
    int begin,
    int end,
    MathCodeFieldThemeData themeData,
  ) =>
      TextSpan(
          text: text.substring(begin, end),
          style: TextStyle(color: themeData.variableColor));

  TextSpan _spanForNumber(
    String text,
    int begin,
    int end,
    MathCodeFieldThemeData themeData,
  ) =>
      TextSpan(
          text: text.substring(begin, end),
          style: TextStyle(color: themeData.numberColor));

  TextSpan _spanForOperator(
    String text,
    int index,
    MathCodeFieldThemeData themeData,
  ) {
    final operator = text[index];
    final isEquals = operator == "=";
    return TextSpan(
      text: text[index],
      style: TextStyle(
        color: isEquals ? themeData.equalsColor : themeData.operatorColor,
        fontWeight:
            isEquals && themeData.equalsIsThick ? FontWeight.bold : null,
      ),
    );
  }

  TextSpan _spanForError(
    String text,
    int begin,
    int end,
    MathCodeFieldThemeData themeData,
  ) =>
      TextSpan(
        text: text.substring(begin, end),
        style: TextStyle(color: themeData.errorColor),
      );
}
