import 'package:flutter/material.dart';
import 'package:ui/src/constants.dart';

/// A custom [TextField] widget designed for secure password input.
///
/// This widget provides a password input field with an optional label,
/// hint text, prefix icon, and a toggle button to show/hide the password.
/// The field can also be configured to be dense,
/// which reduces the height of the input field.
///
/// Example usage:
/// ```dart
/// PasswordField(
///   controller: _passwordController,
///   labelText: 'Password',
///   hintText: 'Enter your password',
///   prefixIcon: Icon(Icons.lock),
///   isDense: true,
/// )
/// ```
///
/// ### Properties:
///
/// - [controller]: A [TextEditingController] to control the text being edited.
/// - [labelText]: An optional [String] to display as the label for the
///   input field.
/// - [helperText]: An optional [String] to display as an info message below
///   the input field on focus.
/// - [errorText]: An optional [String] to display as an error message below
///   the input field.
/// - [hintText]: An optional [String] to display as a hint inside the
///   input field. Defaults to an empty string.
/// - [prefixIcon]: An optional [Widget] to display as a prefix icon inside the
///   input field.
/// - [isDense]: An optional [bool] to determine if the input field should be
///   dense.
///
/// ### State Management:
///
/// The visibility of the password text is managed internally by the widget.
/// A toggle button is provided as a suffix icon to switch between showing and
/// hiding the password.
///
/// ### Styling:
///
/// The widget uses the current [Theme] to style the text and input decoration.
/// The border of the input field is an [OutlineInputBorder] with
/// rounded corners.
class PasswordField extends StatefulWidget {
  /// Creates a [PasswordField] widget.
  ///
  /// The [controller] is required and must not be null.
  const PasswordField({
    required this.controller,
    super.key,
    this.labelText,
    this.helperText,
    this.errorText,
    this.hintText = '',
    this.prefixIcon,
    this.isDense,
  });

  /// The [TextEditingController] to control the text being edited.
  final TextEditingController controller;

  /// An optional [String] to display as the label for the input field.
  final String? labelText;

  /// An optional [String] to display as an info message below the input field
  /// on focus.
  final String? helperText;

  /// An optional [String] to display as an error message below the input field.
  final String? errorText;

  /// An optional [String] to display as a hint inside the input field.
  /// Defaults to an empty string.
  final String? hintText;

  /// An optional [Widget] to display as a prefix icon inside the input field.
  final Widget? prefixIcon;

  /// An optional [bool] to determine if the input field should be dense.
  final bool? isDense;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  /// A boolean flag to control the visibility of the password text.
  bool _obscureText = true;

  /// Toggles the visibility of the password text.
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          return TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              isDense: widget.isDense,
              label: widget.labelText != null
                  ? Text(
                      widget.labelText!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : null,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              helperText:
                  Focus.of(context).hasFocus && widget.helperText != null
                      ? widget.helperText
                      : null,
              helperMaxLines: defaultHelperMaxLines,
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              prefixIcon: widget.prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _toggleVisibility,
              ),
            ),
            obscureText: _obscureText,
          );
        },
      ),
    );
  }
}
