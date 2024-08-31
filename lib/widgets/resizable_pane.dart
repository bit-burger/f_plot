import 'package:flutter/material.dart';

enum ResizableOrientation { horizontal, vertical }

// TODO: fix ResizablePane
// inspired, and some code used from https://github.com/GroovinChip/macos_ui,
// specifically from /lib/src/layout/resizable_pane.dart
class ResizablePane extends StatefulWidget {
  final Widget child;
  final Color? dividerColor;
  final double? dividerWidth;
  final bool dividerIsFromStart;

  final ResizableOrientation orientation;

  final double max;
  final double min;
  final double initialResizeValue;

  const ResizablePane({
    super.key,
    this.orientation = ResizableOrientation.horizontal,
    required this.max,
    required this.min,
    this.dividerColor,
    this.dividerWidth,
    this.dividerIsFromStart = true,
    required this.initialResizeValue,
    required this.child,
  });

  @override
  State<ResizablePane> createState() => _ResizablePaneState();
}

class _ResizablePaneState extends State<ResizablePane> {
  late double _resizeValue;
  late double _resizeStartGlobalPosition;
  late double _resizeStartValue;

  bool get _isHorizontal =>
      widget.orientation == ResizableOrientation.horizontal;

  @override
  void initState() {
    super.initState();
    _resizeValue = widget.initialResizeValue;
  }

  MouseCursor get _mouseCursor {
    final isMax = _resizeValue == widget.max;
    final isMin = _resizeValue == widget.min;
    final isStart = widget.dividerIsFromStart;
    if (isMax || isMin) {
      var isDown = isStart;
      if (isMin) {
        isDown = !isDown;
      }
      if (_isHorizontal) {
        return isDown
            ? SystemMouseCursors.resizeRight
            : SystemMouseCursors.resizeLeft;
      } else {
        return isDown
            ? SystemMouseCursors.resizeDown
            : SystemMouseCursors.resizeUp;
      }
    }
    return _isHorizontal
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeUpDown;
  }

  void onDragStart(DragStartDetails details) {
    _resizeStartValue = _resizeValue;
    _resizeStartGlobalPosition =
        _isHorizontal ? details.globalPosition.dx : details.globalPosition.dy;
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      final currentValue =
          _isHorizontal ? details.globalPosition.dx : details.globalPosition.dy;
      if (widget.dividerIsFromStart) {
        _resizeValue =
            _resizeStartValue + (_resizeStartGlobalPosition - currentValue);
      } else {
        _resizeValue =
            _resizeStartValue - (_resizeStartGlobalPosition - currentValue);
      }
      if (_resizeValue < widget.min) {
        _resizeValue = widget.min;
      } else if (_resizeValue > widget.max) {
        _resizeValue = widget.max;
      }
    });
  }

  Widget _buildDivider(double dividerWidth, Color dividerColor) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: _mouseCursor,
        child: Container(
          width: _isHorizontal ? dividerWidth : double.infinity,
          height: _isHorizontal ? double.infinity : dividerWidth,
          color: dividerColor,
        ),
      ),
      onHorizontalDragStart: _isHorizontal ? onDragStart : null,
      onVerticalDragStart: _isHorizontal ? null : onDragStart,
      onHorizontalDragUpdate: _isHorizontal ? onDragUpdate : null,
      onVerticalDragUpdate: _isHorizontal ? null : onDragUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerTheme = Theme.of(context).dividerTheme;
    final dividerWidth = widget.dividerWidth ?? dividerTheme.thickness ?? 5;
    final dividerColor =
        widget.dividerColor ?? dividerTheme.color ?? Colors.black;
    final divider = _buildDivider(dividerWidth, dividerColor);
    if (_isHorizontal) {
      return SizedBox(
        width: _resizeValue + dividerWidth,
        child: Row(
          children: [
            if (widget.dividerIsFromStart) divider,
            Expanded(child: widget.child),
            if (!widget.dividerIsFromStart) divider,
          ],
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: _resizeValue + dividerWidth,
        maxWidth: double.infinity,
      ),
      child: Column(
        children: [
          if (widget.dividerIsFromStart) divider,
          Expanded(child: widget.child),
          if (!widget.dividerIsFromStart) divider,
        ],
      ),
    );
  }
}
