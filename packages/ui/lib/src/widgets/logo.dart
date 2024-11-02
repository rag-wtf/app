import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// A widget that displays a SVG logo which adapts to the current theme's
/// brightness.
///
/// The `Logo` widget allows you to specify different logos for dark and
/// light themes. It automatically selects the appropriate logo based on the
/// current theme's brightness.
/// Additionally, you can use the [inverse] parameter to invert
/// the logo selection logic.
///
/// Example usage:
/// ```dart
/// Logo(
///   darkLogo: 'assets/logo_dark.svg',
///   lightLogo: 'assets/logo_light.svg',
///   size: 48.0,
///   inverse: true, // Optional, defaults to false
/// )
/// ```
///
/// This widget is particularly useful for branding elements that need to adapt
/// to the app's theme, ensuring a consistent and visually appealing experience.
class Logo extends StatelessWidget {
  /// Creates a [Logo] widget.
  ///
  /// The [darkLogo] and [lightLogo] parameters are required and represent the
  /// paths to the logos for dark and light themes, respectively.
  ///
  /// The [size] parameter determines the dimensions of the logo.
  /// It defaults to 24.0.
  ///
  /// The [inverse] parameter, when set to `true`, inverts the logo selection
  /// logic. This means that the [darkLogo] will be used in light themes and
  /// the [lightLogo] will be used in dark themes. It defaults to `false`.
  ///
  /// The [key] parameter is inherited from [Widget].
  const Logo({
    required this.darkLogo, // Path to dark logo,
    required this.lightLogo, // Path to light logo,
    this.size = 24.0, // Default size is 24.0
    this.inverse = false,
    super.key,
  });

  /// The size of the logo in logical pixels.
  ///
  /// This value determines the width and height of the logo.
  /// It defaults to 24.0.
  final double size;

  /// The path to the logo to be displayed in dark themes.
  ///
  /// This image will be used when the current theme's brightness
  /// is [Brightness.dark], unless the [inverse] parameter is set to `true`.
  final String darkLogo;

  /// The path to the logo to be displayed in light themes.
  ///
  /// This image will be used when the current theme's brightness
  /// is [Brightness.light], unless the [inverse] parameter is set to `true`.
  final String lightLogo;

  /// Determines whether to invert the logo selection logic.
  ///
  /// When set to `true`, the [darkLogo] will be used in light themes and
  /// the [lightLogo] will be used in dark themes. Defaults to `false`.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    /// Retrieves the current theme's brightness.
    final brightness = Theme.of(context).brightness;

    /// Selects the appropriate logo path based on the theme's brightness and
    /// the [inverse] parameter.
    final logoPath = !inverse
        ? (brightness == Brightness.dark ? darkLogo : lightLogo)
        : (brightness == Brightness.dark ? lightLogo : darkLogo);

    /// Returns an [SvgPicture.asset] widget with the selected logo path.
    ///
    /// The image is scaled to fit within the specified [size] while
    /// maintaining its aspect ratio.
    return logoPath.endsWith('.svg.vec')
        ? SvgPicture(
            AssetBytesLoader(logoPath),
            height: size,
            width: size,
          )
        : SvgPicture.asset(
            logoPath,
            height: size,
            width: size,
          );
  }
}
