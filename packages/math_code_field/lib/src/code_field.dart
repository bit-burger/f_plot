import 'package:flutter/material.dart';

import 'code_editing_controller.dart';
import 'style.dart';
import 'code_error.dart';
import 'unconventional_character_filter.dart';

// TODO: add tabs and automatic parentheses completion
/// a text field with highlighting and line numbers for math
class MathCodeField extends StatelessWidget {
  /// the errors that should be displayed,
  /// errors that are not at all inside of the text bounds are not displayed,
  /// and errors that are partly outside of it are only shown the parts inside
  ///
  /// the first error is the most important error
  /// and the last one the least important.
  ///
  /// if two errors overlap,
  /// the part that overlaps shows the error that is more important.
  final List<CodeError> codeErrors;

  /// the text theme to be used, should be mono sized.
  final TextTheme monoTextTheme;

  /// a function that is called when the text changes
  final ValueChanged<String>? textChanged;

  /// a function that is called when the selection/cursor or text changes.
  ///
  /// is called with the first error in [codeErrors],
  /// where the cursor lies in the error
  final ValueChanged<CodeError?>? errorSelectionChanged;

  final MathCodeEditingController? codeEditingController;

  /// if an error should only be counted as selected
  /// if the cursor is inside the error.
  ///
  /// else the first error on the line is taken, or, if it exists,
  /// the error where the cursor is inside
  final bool errorSelectionExact;

  const MathCodeField({
    Key? key,
    this.codeErrors = const [],
    required this.monoTextTheme,
    this.textChanged,
    this.errorSelectionChanged,
    this.errorSelectionExact = true,
    this.codeEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: monoTextTheme,
      ),
      child: _MathCodeField(
        errors: codeErrors,
        textChanged: textChanged,
        errorSelectionChanged: errorSelectionChanged,
        controller: codeEditingController,
        errorSelectionExact: errorSelectionExact,
      ),
    );
  }
}

class _MathCodeField extends StatefulWidget {
  final List<CodeError> errors;
  final ValueChanged<String>? textChanged;
  final ValueChanged<CodeError?>? errorSelectionChanged;
  final bool errorSelectionExact;
  final MathCodeEditingController? controller;

  const _MathCodeField({
    required this.errors,
    Key? key,
    this.textChanged,
    this.errorSelectionChanged,
    this.controller,
    required this.errorSelectionExact,
  }) : super(key: key);

  @override
  State<_MathCodeField> createState() => _MathCodeFieldState();
}

class _MathCodeFieldState extends State<_MathCodeField> {
  late final MathCodeEditingController _controller;
  late TextSelection _lastSelection;
  late CodeError? _lastSelectedError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MathCodeEditingController();
    _lastSelection = _controller.selection;
    _lastSelectedError = null;
    _controller.addListener(_didUpdateController);
    _controller.setErrors(widget.errors);
  }

  void _didUpdateController({bool override = false}) {
    if (override || _controller.selection != _lastSelection) {
      final cursorPosition = _controller.selection.baseOffset;
      var error = _firstErrorThatLiesInCursor(cursorPosition);
      if (!widget.errorSelectionExact && error == null) {
        error = _firstErrorThatLiesInCursorLine(cursorPosition);
      }
      if (error != _lastSelectedError) {
        widget.errorSelectionChanged?.call(error);
      }
      _lastSelectedError = error;
    }
    _lastSelection = _controller.selection;
  }

  // line starts at 0
  bool _errorInLine(int line) {
    final text = _controller.text;
    var firstCharacterCursorLine = 0;
    var currentLine = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == "\n") {
        firstCharacterCursorLine = i + 1;
        currentLine++;
      }
      if (currentLine == line) {
        break;
      }
    }
    var lastCharacterCursorLine = firstCharacterCursorLine;
    while (lastCharacterCursorLine < text.length - 1 &&
        text[lastCharacterCursorLine] != "\n") {
      lastCharacterCursorLine++;
    }
    return _firstErrorInRange(
            firstCharacterCursorLine, lastCharacterCursorLine) !=
        null;
  }

  CodeError? _firstErrorInRange(int begin, int last) {
    for (final codeError in widget.errors) {
      final errorIsBeforeCursorLine =
          last < codeError.begin && last < codeError.begin;
      final errorIsAfterCursorLine =
          begin >= codeError.end && begin >= codeError.end;
      if (!errorIsBeforeCursorLine && !errorIsAfterCursorLine) {
        return codeError;
      }
    }
    return null;
  }

  CodeError? _firstErrorThatLiesInCursorLine(int cursorPosition) {
    final text = _controller.text;
    var firstCharacterCursorLine = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == "\n") {
        firstCharacterCursorLine = i;
      }
      if (i == cursorPosition) {
        break;
      }
    }
    var lastCharacterCursorLine = firstCharacterCursorLine;
    while (lastCharacterCursorLine < text.length - 1 &&
        text[lastCharacterCursorLine] != "\n") {
      lastCharacterCursorLine++;
    }
    return _firstErrorInRange(
        firstCharacterCursorLine, lastCharacterCursorLine);
  }

  CodeError? _firstErrorThatLiesInCursor(int cursorPosition) {
    for (final error in widget.errors) {
      if (cursorPosition >= error.begin && cursorPosition < error.end) {
        return error;
      }
      // make sure a error cannot be marked if it is on the line above,
      // even if it goes to the new line
      if (cursorPosition != 0 &&
          cursorPosition == error.end &&
          _controller.text[cursorPosition - 1] != "\n") {
        return error;
      }
    }
    return null;
  }

  static double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  String get _longestLine {
    if (_controller.value.text.isEmpty) {
      return "";
    }
    final lines = _controller.value.text.split("\n");
    var longestLine = lines[0];
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].length > longestLine.length) {
        longestLine = lines[i];
      }
    }
    return longestLine;
  }

  Widget _buildTextField() {
    return IntrinsicHeight(
      child: TextField(
        onChanged: widget.textChanged,
        inputFormatters: [UnconventionalCharacterFilter()],
        toolbarOptions:
            const ToolbarOptions(copy: true, paste: true, cut: true),
        controller: _controller,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        expands: true,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _MathCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      _controller = widget.controller!;
    }
    _controller.setErrors(widget.errors);
    _didUpdateController(override: true);
  }

  @override
  Widget build(BuildContext context) {
    final themeData =
        MathCodeFieldTheme.of(context) ?? MathCodeFieldThemeData();
    final textStyle = Theme.of(context).textTheme.bodyText1!.merge(
          TextStyle(color: themeData.lineNumberColor, fontSize: 16),
        );
    return TextSelectionTheme(
      data: TextSelectionTheme.of(context).copyWith(
        selectionColor: themeData.selectionColor,
        cursorColor: themeData.cursorColor,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 128),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 4),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (BuildContext context, TextEditingValue value,
                      Widget? widget) =>
                  lineNumberBuilder(
                context,
                value,
                widget,
                textStyle,
                TextStyle(color: themeData.errorColor),
              ),
            ),
            const SizedBox(width: 10),
            // Container(width: 1, color: themeData.lineNumberColor),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller,
                child: _buildTextField(),
                builder: (context, value, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = _textWidth(_longestLine, textStyle) + 24;
                      late final double widthOfScroll;
                      if (width > constraints.maxWidth) {
                        widthOfScroll = width;
                      } else {
                        widthOfScroll = constraints.maxWidth;
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: widthOfScroll,
                          child: child,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lineNumberBuilder(
    BuildContext context,
    TextEditingValue value,
    Widget? widget,
    TextStyle textStyle,
    TextStyle errorTextStyle,
  ) {
    final linesCount = value.text.split("\n").length;
    final maxDigits = linesCount.toString().length;
    final spans = List<TextSpan>.generate(
      linesCount,
      (rawLine) {
        final isError = _errorInLine(rawLine);
        final text = "${(rawLine + 1).toString().padLeft(maxDigits)}\n";
        if (isError) {
          return TextSpan(text: text, style: errorTextStyle);
        }
        return TextSpan(text: text);
      },
    );
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: RichText(
        text: TextSpan(
          children: spans,
          style: textStyle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeListener(_didUpdateController);
    super.dispose();
  }
}
