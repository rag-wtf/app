import 'package:flutter/material.dart';

/// A widget that displays a label with an associated tooltip icon.
///
/// The [TooltipLabel] combines a text label with an informational tooltip
/// that appears when the user hovers over or long-presses the icon.
class TooltipLabel extends StatelessWidget {
  /// Creates a [TooltipLabel].
  ///
  /// The [text] and [tooltipMessage] parameters are required.
  const TooltipLabel({
    required this.text,
    required this.tooltipMessage,
    this.textStyle,
    this.icon = Icons.info_outline,
    this.iconColor = Colors.grey,
    this.iconSize = 16,
    this.padding = const EdgeInsets.only(left: 4),
    this.tooltipBehavior,
    super.key,
  });

  /// The text to display as the label.
  final String text;

  /// The message to display in the tooltip when the icon is interacted with.
  final String tooltipMessage;

  /// The style to apply to the label text.
  ///
  /// If `null`, the default text style will be used.
  final TextStyle? textStyle;

  /// The icon to display next to the label.
  ///
  /// Defaults to [Icons.info_outline].
  final IconData? icon;

  /// The color of the icon.
  ///
  /// Defaults to `Colors.grey`.
  final Color? iconColor;

  /// The size of the icon.
  ///
  /// Defaults to `16`.
  final double? iconSize;

  /// The padding between the label text and the icon.
  ///
  /// Defaults to `EdgeInsets.only(left: 4)`.
  final EdgeInsetsGeometry? padding;

  /// Additional behavior for the tooltip, such as positioning and offset.
  ///
  /// If `null`, default behavior will be used.
  final TooltipBehavior? tooltipBehavior;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: textStyle),
        Padding(
          padding: padding!,
          child: Tooltip(
            message: tooltipMessage,
            preferBelow: tooltipBehavior?.preferBelow ?? true,
            verticalOffset: tooltipBehavior?.verticalOffset ?? 20.0,
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
}

/// Defines behavior for the tooltip, such as whether it should appear below
/// the icon and the vertical offset from the icon.
class TooltipBehavior {
  /// Creates a [TooltipBehavior].
  TooltipBehavior({
    this.preferBelow = true,
    this.verticalOffset = 20.0,
  });

  /// Whether the tooltip should appear below the icon.
  ///
  /// Defaults to `true`.
  final bool preferBelow;

  /// The vertical offset of the tooltip from the icon.
  ///
  /// Defaults to `20.0`.
  final double verticalOffset;
}
