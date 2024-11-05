import 'package:flutter/material.dart';

/// A [StatelessWidget] that displays either a [Checkbox] or [Switch]
/// based on the screen width.
///
/// ## Properties
///
/// - [value]: The current state of the checkbox or switch.
/// - [onChanged]: A callback function that is triggered when the checkbox or
///   switch is toggled. It takes a boolean value representing the new state.
/// - [screenWidthBreakpoint]: The screen width threshold at which the widget
///   switches from a [Switch] to a [Checkbox]. Defaults to 600.
///
/// ## Usage
///
/// ```dart
/// CheckboxOrSwitch(
///   value: _isEnabled,
///   onChanged: (bool newValue) {
///     setState(() {
///       _isEnabled = newValue;
///     });
///   },
///   screenWidthBreakpoint: 800,
/// )
/// ```
///
/// In this example, the widget will display a [Switch] on screens
/// narrower than 800 pixels and a [Checkbox] on wider screens.
class CheckboxOrSwitch extends StatelessWidget {
  /// Creates a [CheckboxOrSwitch].
  ///
  /// The [value] and [onChanged] parameters are required.
  /// The [screenWidthBreakpoint] has a default value.
  const CheckboxOrSwitch({
    required this.value,
    required this.onChanged,
    this.screenWidthBreakpoint = 600,
    super.key,
  });

  /// The current state of the checkbox or switch.
  final bool value;

  /// A callback function that is triggered when the checkbox or
  /// switch is toggled.
  final ValueChanged<bool> onChanged;

  /// The screen width threshold at which the widget switches from
  /// a [Switch] to a [Checkbox]. Defaults to 600.
  final double screenWidthBreakpoint;

  @override
  Widget build(BuildContext context) {
    // Get the current screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Determine which widget to display based on the screen width
    if (screenWidth < screenWidthBreakpoint) {
      return Switch(
        value: value,
        onChanged: onChanged,
      );
    } else {
      return Checkbox(
        value: value,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      );
    }
  }
}
