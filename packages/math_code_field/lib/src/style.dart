import 'package:flutter/material.dart';
import 'code_field.dart';

/// the [MathCodeFieldThemeData] providing widget
class MathCodeFieldTheme extends InheritedWidget {
  final MathCodeFieldThemeData data;

  const MathCodeFieldTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static MathCodeFieldThemeData? of(BuildContext context) {
    final MathCodeFieldTheme? result =
        context.dependOnInheritedWidgetOfExactType<MathCodeFieldTheme>();
    return result?.data;
  }

  @override
  bool updateShouldNotify(MathCodeFieldTheme oldWidget) {
    return oldWidget.data != data;
  }
}

/// a theme for the [MathCodeField]
class MathCodeFieldThemeData {
  final Color operatorColor;
  final Color numberColor;
  final Color variableColor;
  final List<Color> bracketColors;
  final Color errorColor;
  final Color lineNumberColor;
  final Color cursorColor;
  final Color selectionColor;
  final Color equalsColor;
  final bool equalsIsThick;
  final TextStyle errorTextStyle;
  final TextStyle restStyle;

  MathCodeFieldThemeData({
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
    Color? equalsColor = const Color(0xFFFF71B2),
    this.equalsIsThick = true,
    this.errorTextStyle = const TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: Colors.red,
    ),
    this.restStyle = const TextStyle(color: Color(0xFF000000)),
  })  : assert(bracketColors.isNotEmpty),
        equalsColor = equalsColor ?? operatorColor;

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
