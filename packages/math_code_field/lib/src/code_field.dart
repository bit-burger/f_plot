import 'package:flutter/material.dart';
import 'package:math_code_field/src/code_editing_controller.dart';
import 'package:math_code_field/src/style.dart';

class MathCodeField extends StatefulWidget {
  final CodeFieldThemeData? theme;

  const MathCodeField({
    Key? key,
    this.theme,
  }) : super(key: key);

  @override
  State<MathCodeField> createState() => _MathCodeFieldState();
}

class _MathCodeFieldState extends State<MathCodeField> {
  CodeFieldThemeData get _effectiveThemeData =>
      widget.theme ?? CodeFieldTheme.of(context);

  late final CodeEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionTheme.of(context).copyWith(
        selectionColor: _effectiveThemeData.selectionColor,
        cursorColor: _effectiveThemeData.cursorColor,
      ),
      child: SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 4),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: lineNumberBuilder,
            ),
            const SizedBox(width: 10),
            // Container(width: 1, color: themeData.lineNumberColor),
            Expanded(
              child: IntrinsicHeight(
                child: TextField(
                  toolbarOptions:
                      const ToolbarOptions(copy: true, paste: true, cut: true),
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  expands: true,
                ),
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
  ) {
    final linesCount = value.text.split("\n").length;
    final linesText = List.generate(
      linesCount,
      (rawLine) {
        return (rawLine + 1).toString();
      },
    ).reduce((value, element) => "$value\n$element");
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Text(
        linesText,
        style: TextStyle(
          color: _effectiveThemeData.lineNumberColor,
          fontSize: 16,
        ).copyWith(
          fontFamily: _effectiveThemeData.monoFontFamily,
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = CodeEditingController(_effectiveThemeData);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
