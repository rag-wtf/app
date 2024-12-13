import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable widget that displays a clickable tile with an image, title, 
/// and URL.
///
/// The tile opens the specified [url] when tapped. It also provides optional
/// customization for the image size, text style, and a callback when the URL 
/// is launched.
class LinkTile extends StatelessWidget {
  /// Creates a [LinkTile] widget.
  ///
  /// The [imagePath] is the asset path to the image displayed on the leading 
  /// side of the tile.
  /// The [title] is the text displayed in the tile.
  /// The [url] is the URI that will be opened when the tile is tapped.
  /// The [imageSize] is the size of the leading image (default is 24).
  /// The [textStyle] is the optional text style for the title.
  /// The [onUrlLaunched] is an optional callback that is invoked after the URL 
  /// is successfully launched.
  const LinkTile({
    required this.imagePath,
    required this.title,
    required this.url,
    this.imageSize = 24,
    this.textStyle,
    this.onUrlLaunched,
    super.key,
  });

  /// The asset path to the image displayed on the leading side of the tile.
  final String imagePath;

  /// The text displayed in the tile.
  final String title;

  /// The URI that will be opened when the tile is tapped.
  final Uri url;

  /// The size of the leading image. Defaults to 24.
  final double? imageSize;

  /// The optional text style for the title.
  final TextStyle? textStyle;

  /// An optional callback that is invoked after the URL is successfully 
  /// launched.
  final void Function(Uri url)? onUrlLaunched;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        width: imageSize,
        height: imageSize,
      ),
      title: Text(
        title,
        style: textStyle,
      ),
      onTap: () async {
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
          if (onUrlLaunched != null) {
            onUrlLaunched?.call(url);
          }
        } else {
          throw Exception('Could not launch $url');
        }
      },
    );
  }
}
