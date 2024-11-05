import 'package:flutter/material.dart';

/// A [StatelessWidget] that displays either a [CheckboxListTile] or
/// a [SwitchListTile] based on the screen width.
///
/// This widget is useful for creating responsive UIs where the type of control
/// (checkbox or switch) should change depending on the screen size. By default,
/// it uses a [SwitchListTile] for screens narrower than [screenWidthBreakpoint]
/// and a [CheckboxListTile] for wider screens.
///
/// ## Properties
///
/// - [title]: The primary content of the list tile. Typically a [Text] widget.
/// - [value]: The current state of the checkbox or switch.
/// - [onChanged]: A callback function that is triggered when the checkbox or
///   switch is toggled. It takes a boolean value representing the new state.
/// - [screenWidthBreakpoint]: The screen width threshold at which the widget
///   switches from a [SwitchListTile] to a [CheckboxListTile]. Defaults to 600.
/// - [controlAffinity]: Determines the position of the checkbox or switch
///   relative to the text. Defaults to [ListTileControlAffinity.platform],
///   which follows the platform's default behavior.
///
/// ## Usage
///
/// ```dart
/// CheckboxOrSwitchListTile(
///   title: Text('Enable Notifications'),
///   value: _isEnabled,
///   onChanged: (bool newValue) {
///     setState(() {
///       _isEnabled = newValue;
///     });
///   },
///   screenWidthBreakpoint: 800,
///   controlAffinity: ListTileControlAffinity.leading,
/// )
/// ```
///
/// In this example, the widget will display a [SwitchListTile] on screens
/// narrower than 800 pixels and a [CheckboxListTile] on wider screens.
///
/// ## Notes
///
/// - The [onChanged] callback for [CheckboxListTile] is wrapped to ensure it
///   only triggers when a non-null value is provided.
/// - The [controlAffinity] property is shared between both [CheckboxListTile]
///   and [SwitchListTile] to maintain consistency in the UI.
class CheckboxOrSwitchListTile extends StatelessWidget {
  /// Creates a [CheckboxOrSwitchListTile].
  ///
  /// The [title], [value], and [onChanged] parameters are required.
  /// The [screenWidthBreakpoint] and [controlAffinity] parameters
  /// have default values.
  const CheckboxOrSwitchListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.screenWidthBreakpoint = 600,
    this.controlAffinity = ListTileControlAffinity.platform,
    super.key,
  });

  /// The primary content of the list tile. Typically a [Text] widget.
  final Widget title;

  /// The current state of the checkbox or switch.
  final bool value;

  /// Determines the position of the checkbox or switch relative to the text.
  final ListTileControlAffinity controlAffinity;

  /// A callback function that is triggered when the checkbox or
  /// switch is toggled.
  final ValueChanged<bool> onChanged;

  /// The screen width threshold at which the widget switches from
  /// a [SwitchListTile] to a [CheckboxListTile]. Defaults to 600.
  final double screenWidthBreakpoint;

  @override
  Widget build(BuildContext context) {
    // Get the current screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Determine which widget to display based on the screen width
    if (screenWidth < screenWidthBreakpoint) {
      return SwitchListTile(
        title: title,
        value: value,
        controlAffinity: controlAffinity,
        onChanged: onChanged,
      );
    } else {
      return CheckboxListTile(
        title: title,
        value: value,
        controlAffinity: controlAffinity,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      );
    }
  }
}
