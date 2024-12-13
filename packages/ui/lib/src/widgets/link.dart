import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A customizable link widget that launches a URL when tapped.
///
/// This widget supports various features such as custom text styles,
/// hover effects, disabled states, tooltips, animations, and more.
class Link extends StatelessWidget {
  /// Creates a [Link].
  ///
  /// The [url] and [text] parameters are required.
  const Link({
    required this.url,
    required this.text,
    this.onUrlLaunched,
    this.textStyle,
    this.hoverTextStyle,
    this.disabledTextStyle,
    this.isEnabled = true,
    this.hoverColor,
    this.splashColor,
    this.tooltip,
    this.tooltipTextStyle,
    this.tooltipBackgroundColor,
    this.tooltipPosition = TooltipPosition.top,
    this.underlineOnHover = true,
    this.underlineByDefault = true,
    this.cursor,
    this.onDisabledTap,
    this.hoverAnimationDuration,
    this.hoverAnimationCurve,
    this.tooltipAnimationDuration,
    this.tooltipAnimationCurve,
    this.disabledTooltip,
    this.rippleRadius,
    this.padding,
    this.border,
    super.key,
  });

  /// The URL to be launched when the link is tapped.
  final Uri url;

  /// The text displayed for the link.
  final String text;

  /// A callback function that is invoked after the URL is successfully
  /// launched.
  ///
  /// The callback receives the [url] as a parameter.
  final UrlLaunchedCallback? onUrlLaunched;

  /// The custom text style for the link.
  ///
  /// If not provided, a default style with blue color and underline decoration
  /// will be used.
  final TextStyle? textStyle;

  /// The custom text style for the link when hovered.
  ///
  /// If not provided, the [textStyle] will be used.
  final TextStyle? hoverTextStyle;

  /// The custom text style for the link when it is disabled.
  ///
  /// If not provided, a default style with grey color and strikethrough
  /// decoration will be used.
  final TextStyle? disabledTextStyle;

  /// Whether the link is enabled or disabled.
  ///
  /// Defaults to `true`. If set to `false`, the link will not be tappable.
  final bool isEnabled;

  /// The custom hover color for the link.
  ///
  /// This color is applied when the user hovers over the link.
  final Color? hoverColor;

  /// The custom splash color for the link.
  ///
  /// This color is applied when the link is tapped.
  final Color? splashColor;

  /// The tooltip text displayed when the user hovers over the link.
  final String? tooltip;

  /// The custom text style for the tooltip.
  final TextStyle? tooltipTextStyle;

  /// The custom background color for the tooltip.
  final Color? tooltipBackgroundColor;

  /// The position of the tooltip relative to the link.
  ///
  /// Defaults to [TooltipPosition.top].
  final TooltipPosition tooltipPosition;

  /// Whether the link should have an underline when hovered.
  ///
  /// Defaults to `true`.
  final bool underlineOnHover;

  /// Whether the link should have an underline by default.
  ///
  /// Defaults to `true`.
  final bool underlineByDefault;

  /// The custom cursor to be displayed when the user interacts with the link.
  ///
  /// Defaults to [SystemMouseCursors.click] when enabled and
  /// [SystemMouseCursors.basic] when disabled.
  final MouseCursor? cursor;

  /// A custom action to be performed when the link is disabled and tapped.
  ///
  /// This is useful for showing a message or performing an alternative action.
  final VoidCallback? onDisabledTap;

  /// The duration of the hover animation.
  ///
  /// Defaults to 200 milliseconds.
  final Duration? hoverAnimationDuration;

  /// The curve of the hover animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve? hoverAnimationCurve;

  /// The duration of the tooltip animation.
  ///
  /// Defaults to 300 milliseconds.
  final Duration? tooltipAnimationDuration;

  /// The curve of the tooltip animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve? tooltipAnimationCurve;

  /// The tooltip text displayed when the link is disabled.
  final String? disabledTooltip;

  /// The radius of the ripple effect when the link is tapped.
  ///
  /// Defaults to 4.0.
  final double? rippleRadius;

  /// The padding around the link.
  ///
  /// Defaults to no padding.
  final EdgeInsetsGeometry? padding;

  /// The border around the link.
  ///
  /// Defaults to no border.
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isEnabled ? tooltip ?? '' : disabledTooltip ?? '',
      textStyle: tooltipTextStyle,
      decoration: BoxDecoration(
        color: tooltipBackgroundColor ?? Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      preferBelow: tooltipPosition == TooltipPosition.bottom,
      verticalOffset: 8,
      waitDuration: const Duration(milliseconds: 500),
      showDuration:
          tooltipAnimationDuration ?? const Duration(milliseconds: 300),
      child: InkWell(
        onTap: isEnabled
            ? () async {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                  if (onUrlLaunched != null) {
                    onUrlLaunched?.call(url);
                  }
                } else {
                  throw Exception('Could not launch $url');
                }
              }
            : onDisabledTap,
        splashColor: splashColor,
        hoverColor: hoverColor,
        mouseCursor: cursor ??
            (isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        borderRadius: BorderRadius.circular(rippleRadius ?? 4),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(4),
          ),
          child: MouseRegion(
            cursor: cursor ??
                (isEnabled
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic),
            child: AnimatedDefaultTextStyle(
              duration:
                  hoverAnimationDuration ?? const Duration(milliseconds: 200),
              curve: hoverAnimationCurve ?? Curves.easeInOut,
              style: isEnabled
                  ? (hoverTextStyle ??
                      textStyle ??
                      TextStyle(
                        color: Colors.blue,
                        decoration: underlineByDefault
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ))
                  : (disabledTextStyle ??
                      const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      )),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enum for specifying the position of the tooltip relative to the link.
enum TooltipPosition {
  /// Tooltip appears above the link.
  top,

  /// Tooltip appears below the link.
  bottom,

  /// Tooltip appears to the left of the link.
  left,

  /// Tooltip appears to the right of the link.
  right,
}

/// A callback function that is invoked after a URL is successfully launched.
///
/// The callback receives the [url] as a parameter.
typedef UrlLaunchedCallback = void Function(Uri url);
