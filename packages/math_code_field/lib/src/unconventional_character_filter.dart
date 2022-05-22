import 'package:flutter/services.dart';

/// filters out everything except non letters and whitespace,
/// letters such as é, are counted as letters, emojis for example, are not
class UnconventionalCharacterFilter extends TextInputFormatter {
  final normalCharacterRegExp = RegExp(
    r"\p{L}\p{Mn}*|\p{N}| |[\u0021-\u0040\u007B-\u007E]",
    unicode: true,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final length = text.length;
    var s = StringBuffer();
    for (var i = 0; i < length; i++) {
      final char = text[i];
      if (normalCharacterRegExp.hasMatch(char)) {
        s.write(char);
      }
    }
    late final TextSelection selection;
    if (newValue.selection.isCollapsed &&
        newValue.selection.baseOffset > s.length) {
      selection = TextSelection(
        baseOffset: s.length - 1,
        extentOffset: s.length - 1,
      );
    } else {
      selection = newValue.selection;
    }
    return newValue.copyWith(text: s.toString(), selection: selection);
  }
}