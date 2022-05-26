import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

final ThemeData _baseTheme = NordTheme.dark();

final ThemeData fPlotTheme = _baseTheme.copyWith(
  useMaterial3: true,
  splashColor: Colors.white.withAlpha(32),
  hoverColor: Colors.white.withAlpha(12),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.resolveWith(
        (states) {
          const enabledSide = BorderSide(color: NordColors.$8, width: 2);
          const disabledSide = BorderSide(color: Color(0xFF838486), width: 2);
          if(states.contains(MaterialState.disabled)) {
            return disabledSide;
          }
          return enabledSide;
        },
      ),
    ),
  ),
);
