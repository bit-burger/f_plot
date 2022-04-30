import 'package:flutter/material.dart';

class CodeFieldTheme extends InheritedWidget {
  final CodeFieldThemeData data;

  const CodeFieldTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static CodeFieldThemeData of(BuildContext context) {
    final CodeFieldTheme? result =
        context.dependOnInheritedWidgetOfExactType<CodeFieldTheme>();
    assert(
      result != null,
      "A CodeFieldTheme widget has to be found either in the widget hierarchy,"
      "or provided to the MathCodeField constructor",
    );
    return result!.data;
  }

  @override
  bool updateShouldNotify(CodeFieldTheme oldWidget) {
    return oldWidget.data != data;
  }
}

class CodeFieldThemeData {
  final String monoFontFamily;
  final Color operatorColor;
  final Color numberColor;
  final Color variableColor;
  final List<Color> bracketColors;
  final Color errorColor;
  final Color lineNumberColor;
  final Color cursorColor;
  final Color selectionColor;

  CodeFieldThemeData({
    required this.monoFontFamily,
    this.operatorColor = Colors.blue,
    this.numberColor = const Color(0xFFDAC776),
    this.variableColor = const Color(0xFF00b2d2),
    this.bracketColors = const [
      Colors.lightGreen,
      Colors.deepPurple,
      Colors.teal,
    ],
    this.errorColor = Colors.red,
    this.lineNumberColor = const Color(0xFF616161),
    this.cursorColor = Colors.white12,
    this.selectionColor = const Color(0xFF5e5e5e),
  }) : assert(bracketColors.isNotEmpty);

  /// first bracket starts at 1
  Color bracketColorForDepth(int depth) {
    assert(depth > 0);
    return bracketColors[0];
    // return bracketColors[(bracketColors.length % depth) - 1];
  }
}
