import 'package:flutter/material.dart';

class CodeFieldTheme extends InheritedWidget {
  final CodeFieldThemeData data;

  const CodeFieldTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static CodeFieldThemeData? of(BuildContext context) {
    final CodeFieldTheme? result =
        context.dependOnInheritedWidgetOfExactType<CodeFieldTheme>();
    return result?.data;
  }

  @override
  bool updateShouldNotify(CodeFieldTheme oldWidget) {
    return oldWidget.data != data;
  }
}

class CodeFieldThemeData {
  final Color operatorColor;
  final Color numberColor;
  final Color variableColor;
  final List<Color> bracketColors;
  final Color errorColor;
  final Color lineNumberColor;
  final Color cursorColor;
  final Color selectionColor;

  CodeFieldThemeData({
    this.operatorColor = Colors.blue,
    this.numberColor = const Color(0xFFDAC776),
    this.variableColor = const Color(0xFF00b2d2),
    this.bracketColors = const [
      Colors.white,
      Colors.lightGreen,
      Colors.blueGrey,
      Colors.lightBlueAccent,
    ],
    this.errorColor = Colors.red,
    this.lineNumberColor = const Color(0xFF616161),
    this.cursorColor = Colors.white12,
    this.selectionColor = const Color(0xFF5e5e5e),
  }) : assert(bracketColors.isNotEmpty);

  /// first bracket starts at [depth] = 1
  Color bracketColorForDepth(int depth) {
    assert(depth > 0);
    depth--;
    var index = 0;
    var i = 0;
    while (i < depth) {
      index++;
      if (index == bracketColors.length) {
        index = 0;
      }
      i++;
    }
    return bracketColors[index];
  }
}
