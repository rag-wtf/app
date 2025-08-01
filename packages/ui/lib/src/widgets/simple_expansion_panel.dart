import 'package:flutter/material.dart';

/// A simple wrapper class for creating an [ExpansionPanel] with a consistent
/// design and behavior.
///
/// This class simplifies the creation of an [ExpansionPanel] by encapsulating
/// the common properties and behavior into a single constructor. It allows you
/// to easily define the header text, body content, and expansion state of the
/// panel.
///
/// Example usage:
/// ```dart
/// SimpleExpansionPanel(
///   headerText: 'Panel Header',
///   body: Text('Panel Body Content'),
///   isExpanded: false,
/// ).build(context);
/// ```
class SimpleExpansionPanel {
  /// Creates a [SimpleExpansionPanel].
  ///
  /// The [headerText] is the text displayed in the header of the panel.
  /// The [body] is the content displayed when the panel is expanded.
  /// The [isExpanded] flag determines whether the panel is initially expanded
  /// or collapsed.
  const SimpleExpansionPanel({
    required this.headerText,
    required this.body,
    required this.isExpanded,
  });

  /// The text displayed in the header of the expansion panel.
  final String headerText;

  /// The content displayed when the expansion panel is expanded.
  final Widget body;

  /// A flag indicating whether the expansion panel is initially expanded.
  final bool isExpanded;

  /// Builds and returns an [ExpansionPanel] based on the provided properties.
  ///
  /// The context is used to access the theme's text styles for the header.
  ///
  /// Returns an [ExpansionPanel] with the following properties:
  /// - headerBuilder: A [ListTile] with the [headerText] styled using the
  ///   theme's [TextTheme.titleMedium].
  /// - [body]: The provided [body] content wrapped in a [Padding] widget with
  ///   left and right padding of 16.
  /// - backgroundColor: Transparent to avoid overriding the default panel
  ///   background.
  /// - [isExpanded]: The value of the [isExpanded] flag.
  /// - canTapOnHeader: Allows tapping on the header to toggle the panel's
  ///   expansion state.
  ExpansionPanel build(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(
            headerText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: body,
      ),
      backgroundColor: Colors.transparent,
      isExpanded: isExpanded,
      canTapOnHeader: true,
    );
  }
}
