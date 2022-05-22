import 'package:flutter/material.dart';

import 'code_editing_controller.dart';
import 'style.dart';
import 'code_error.dart';
import 'unconventional_character_filter.dart';

// TODO: add tabs and automatic parentheses completion
/// a text field with highlighting and line numbers for math
class MathCodeField<ErrorType extends CodeError> extends StatelessWidget {
  /// the errors that should be displayed,
  /// errors that are not at all inside of the text bounds are not displayed,
  /// and errors that are partly outside of it are only shown the parts inside
  ///
  /// the first error is the most important error
  /// and the last one the least important.
  ///
  /// if two errors overlap,
  /// the part that overlaps shows the error that is more important.
  final List<ErrorType> codeErrors;

  /// the text theme to be used, should be mono sized.
  final TextTheme monoTextTheme;

  /// a function that is called when the text changes
  final ValueChanged<String>? textChanged;

  /// a function that is called when the selection/cursor or text changes.
  ///
  /// is called with the first error in [codeErrors],
  /// where the cursor lies in the error
  final ValueChanged<ErrorType?>? errorSelectionChanged;

  const MathCodeField({
    Key? key,
    this.codeErrors = const [],
    required this.monoTextTheme,
    this.textChanged,
    this.errorSelectionChanged,
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
      ),
    );
  }
}

class _MathCodeField<ErrorType> extends StatefulWidget {
  final List<CodeError> errors;
  final ValueChanged<String>? textChanged;
  final ValueChanged<ErrorType?>? errorSelectionChanged;

  const _MathCodeField({
    required this.errors,
    Key? key,
    this.textChanged,
    this.errorSelectionChanged,
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
    _controller = MathCodeEditingController();
    _lastSelection = _controller.selection;
    _lastSelectedError = null;
    _controller.addListener(_didUpdateController);
  }

  void _didUpdateController() {
    if (_controller.selection != _lastSelection) {
      final error =
          _firstErrorThatLiesInCursor(_controller.selection.baseOffset);
      if (error != _lastSelectedError) {
        widget.errorSelectionChanged?.call(error);
      }
      _lastSelectedError = error;
    }
    _lastSelection = _controller.selection;
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
    _controller.setErrors(widget.errors);
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
                  lineNumberBuilder(context, value, widget, textStyle),
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
  ) {
    final linesCount = value.text.split("\n").length;
    final maxDigits = linesCount.toString().length;
    final linesText = List.generate(
      linesCount,
      (rawLine) {
        return (rawLine + 1).toString().padLeft(maxDigits);
      },
    ).reduce((value, element) => "$value\n$element");
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Text(
        linesText,
        style: textStyle,
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
