import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

final ThemeData _baseTheme = NordTheme.dark();
ThemeData get fPlotTheme => ThemeData.from(
      colorScheme: const ColorScheme(
        primary: NordColors.$1,
        onPrimary: NordColors.$4,
        secondary: NordColors.$8,
        onSecondary: NordColors.$6,
        background: NordColors.$0,
        onBackground: NordColors.$4,
        surface: NordColors.$1,
        onSurface: NordColors.$5,
        error: NordColors.$11,
        onError: NordColors.$5,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: NordColors.$5,
        displayColor: NordColors.$0,
      ),
      useMaterial3: true,
    ).copyWith(
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(NordColors.$0),
        fillColor: MaterialStateProperty.all(NordColors.$10),
        shape: const ContinuousRectangleBorder(),
        // side: BorderSide(width: 3, color: NordColors.$10),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: NordColors.$10,
        ),
        textStyle: TextStyle(color: NordColors.$6),
      ),
      listTileTheme: const ListTileThemeData(
        selectedColor: NordColors.$4,
        selectedTileColor: NordColors.$1,
      ),
      dividerTheme: const DividerThemeData(
        color: NordColors.$1,
        thickness: 3,
        space: 3,
      ),
    );

final ThemeData bfPlotTheme = _baseTheme.copyWith(
  useMaterial3: true,
  splashColor: Colors.white.withAlpha(32),
  hoverColor: Colors.white.withAlpha(12),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.resolveWith(
        (states) {
          const enabledSide = BorderSide(color: NordColors.$8, width: 2);
          const disabledSide = BorderSide(color: Color(0xFF838486), width: 2);
          if (states.contains(MaterialState.disabled)) {
            return disabledSide;
          }
          return enabledSide;
        },
      ),
    ),
  ),
  tooltipTheme: const TooltipThemeData(
    decoration: BoxDecoration(
      color: NordColors.$10,
    ),
    textStyle: TextStyle(color: NordColors.$6),
  ),
);
