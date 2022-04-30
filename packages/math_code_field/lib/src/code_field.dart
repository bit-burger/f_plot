import 'package:flutter/material.dart';
import 'package:math_code_field/src/code_editing_controller.dart';
import 'package:math_code_field/src/style.dart';

class MathCodeField extends StatelessWidget {
  final TextTheme monoTextTheme;
  const MathCodeField({
    Key? key,
    required this.monoTextTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: monoTextTheme,
      ),
      child: const _MathCodeField(),
    );
  }
}

class _MathCodeField extends StatefulWidget {
  const _MathCodeField({Key? key}) : super(key: key);

  @override
  State<_MathCodeField> createState() => _MathCodeFieldState();
}

class _MathCodeFieldState extends State<_MathCodeField> {
  final _controller = CodeEditingController();

  @override
  Widget build(BuildContext context) {
    final themeData = CodeFieldTheme.of(context) ?? CodeFieldThemeData();
    return TextSelectionTheme(
      data: TextSelectionTheme.of(context).copyWith(
        selectionColor: themeData.selectionColor,
        cursorColor: themeData.cursorColor,
      ),
      child: SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 4),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (BuildContext context, TextEditingValue value,
                      Widget? widget) =>
                  lineNumberBuilder(context, value, widget, themeData),
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
    CodeFieldThemeData themeData,
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
        style: Theme.of(context).textTheme.bodyText1!.merge(
              TextStyle(color: themeData.lineNumberColor, fontSize: 16),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
