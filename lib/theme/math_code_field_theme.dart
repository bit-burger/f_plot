import 'package:flutter/material.dart';
import 'package:math_code_field/math_code_field.dart';

import "colors.dart";

final mathCodeFieldTheme = MathCodeFieldThemeData(
  numberColor: NordColors.$13,
  errorColor: NordColors.$11,
  cursorColor: NordColors.$10,
  equalsColor: NordColors.$15,
  operatorColor: NordColors.$15,
  lineNumberColor: NordColors.$3,
  variableColor: NordColors.$14,
  bracketColors: const [
    NordColors.$7,
    NordColors.$9,
    NordColors.$8,
    NordColors.$10,
  ],
  selectionColor: NordColors.$1,
  errorTextStyle: const TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: NordColors.$11,
  ),
  restStyle: const TextStyle(color: NordColors.$4),
);
