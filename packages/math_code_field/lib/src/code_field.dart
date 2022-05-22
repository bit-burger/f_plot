import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'code_editing_controller.dart';
import 'style.dart';
import 'code_error.dart';
import 'unconventional_character_filter.dart';

/// a text field with highlighting and line numbers for math
class MathCodeField extends StatelessWidget {
  final List<CodeError> codeErrors;
  final TextTheme monoTextTheme;

  const MathCodeField({
    Key? key,
    this.codeErrors = const [],
    required this.monoTextTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: monoTextTheme,
      ),
      child: _MathCodeField(errors: codeErrors),
    );
  }
}

class _MathCodeField extends StatefulWidget {
  final List<CodeError> errors;

  const _MathCodeField({required this.errors, Key? key}) : super(key: key);

  @override
  State<_MathCodeField> createState() => _MathCodeFieldState();
}

class _MathCodeFieldState extends State<_MathCodeField> {
  final _controller = MathCodeEditingController();

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
    super.dispose();
  }
}
