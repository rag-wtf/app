import 'package:flutter/material.dart';

/// An adaptive dialog widget that switches between a fullscreen and
/// a constrained dialog based on screen width.
///
/// This widget is designed to provide a responsive dialog experience by
/// automatically switching to a fullscreen dialog on smaller screens and
/// a constrained dialog on larger screens. It is particularly useful in
/// applications where you want to ensure a consistent user experience across
/// different screen sizes.
///
/// Example usage:
/// ```dart
/// AdaptiveDialog(
///   child: MyCustomContent(),
///   shape: RoundedRectangleBorder(
///     borderRadius: BorderRadius.circular(12),
///   ),
///   backgroundColor: Colors.white,
///   fullScreenWidthBreakpoint: 500,
///   maxWidth: 300,
///   maxHeight: 200,
/// )
/// ```
///
/// Inspired by [YouTube video](https://www.youtube.com/watch?v=LeKLGzpsz9I).
class AdaptiveDialog extends StatelessWidget {
  /// Creates an [AdaptiveDialog] widget.
  ///
  /// The [child] parameter is required and represents the content of the dialog
  /// The [shape], [backgroundColor], [fullScreenWidthBreakpoint], [maxWidth],
  /// and [maxHeight] parameters are optional and allow customization of the
  /// dialog's appearance and behavior.
  const AdaptiveDialog({
    required this.child,
    this.shape,
    this.backgroundColor,
    this.fullScreenWidthBreakpoint = 600,
    this.maxWidth = 400,
    this.maxHeight = double.infinity,
    super.key,
  });

  /// The content to be displayed inside the dialog.
  final Widget child;

  /// The shape of the dialog. Defaults to `null`.
  final ShapeBorder? shape;

  /// The background color of the dialog. Defaults to `null`.
  final Color? backgroundColor;

  /// The screen width breakpoint at which the dialog switches to
  /// fullscreen mode.
  /// Defaults to `600`.
  final double fullScreenWidthBreakpoint;

  /// The maximum width of the dialog when it is not in fullscreen mode.
  /// Defaults to `400`.
  final double maxWidth;

  /// The maximum height of the dialog when it is not in fullscreen mode.
  /// Defaults to `double.infinity`.
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
