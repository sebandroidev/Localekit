import 'package:flutter/material.dart';
import 'package:localekit/core/theme/app_colors.dart';

/// A vertical drag handle that lets the user resize adjacent panes.
///
/// Call [onDelta] with the horizontal delta in logical pixels as the
/// user drags. The parent is responsible for clamping the resulting width.
class DragDivider extends StatefulWidget {
  const DragDivider({required this.onDelta, super.key});

  final void Function(double delta) onDelta;

  @override
  State<DragDivider> createState() => _DragDividerState();
}

class _DragDividerState extends State<DragDivider> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) =>
            widget.onDelta(details.delta.dx),
        child: SizedBox(
          width: 4,
          child: Center(
            child: Container(
              width: 1,
              color: _hovering
                  ? AppColors.brand.withAlpha(180)
                  : AppColors.darkBorder,
            ),
          ),
        ),
      ),
    );
  }
}
