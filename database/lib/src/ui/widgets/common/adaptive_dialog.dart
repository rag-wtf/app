import 'package:flutter/material.dart';

// REF: https://www.youtube.com/watch?v=LeKLGzpsz9I
class AdaptiveDialog extends StatelessWidget {
  const AdaptiveDialog({
    required this.child,
    this.shape,
    this.backgroundColor,
    this.fullScreenWidthBreakpoint = 600,
    this.maxWidth = 400,
    this.maxHeight = double.infinity,
    super.key,
  });
  final Widget child;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final double fullScreenWidthBreakpoint;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final showFullScreen =
        MediaQuery.sizeOf(context).width < fullScreenWidthBreakpoint;

    if (showFullScreen) {
      return Dialog.fullscreen(
        child: child,
      );
    } else {
      return Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: maxWidth,
          ),
          child: child,
        ),
      );
    }
  }
}
