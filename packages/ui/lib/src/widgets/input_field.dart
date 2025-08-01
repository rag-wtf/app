import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/constants.dart';

/// A customizable [StatelessWidget] for input fields.
///
/// This widget provides a flexible input field with various customization
/// options, including label text, hint text, input formatters, keyboard type,
/// prefix and suffix icons, and more.
/// It also supports displaying an error message and a clear text button.
///
/// Example usage:
/// ```dart
/// InputField(
///   controller: _textController,
///   labelText: 'Username',
///   hintText: 'Enter your username',
///   prefixIcon: Icon(Icons.person),
///   inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
///   textInputType: TextInputType.text,
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
/// - [inputFormatters]: An optional list of [TextInputFormatter] to apply to
///   the input field.
/// - [textInputType]: An optional [TextInputType] to specify the type of
///   keyboard to display.
/// - [prefixIcon]: An optional [Widget] to display as a prefix icon inside the
///   input field.
/// - [suffixIcon]: An optional [Widget] to display as a suffix icon inside the
///   input field.
/// - [showClearTextButton]: A boolean to determine if a clear text button
///   should be shown when the input field is focused and contains text.
///   Defaults to `true`.
/// - [enabled]: A boolean to determine if the input field is enabled.
///   Defaults to `true`.
/// - [readOnly]: A boolean to determine if the input field is read-only.
///   Defaults to `false`.
/// - [maxLines]: An optional integer to specify the maximum number of lines
///   for the input field. Defaults to `1`.
/// - [isDense]: An optional boolean to determine if the input field
///   should be dense.
/// - [verticalPadding]: An optional double to determine the vertical padding 
///   of the input field. Defaults to `8`.
///
/// ### Styling:
///
/// The widget uses the current [Theme] to style the text and input decoration.
/// The border of the input field is an [OutlineInputBorder] with
/// rounded corners.
/// The error message is styled with a bold font and the theme's error color.
class InputField extends StatelessWidget {
  /// Creates an [InputField] widget.
  ///
  /// The [controller] is required and must not be null.
  const InputField({
    required this.controller,
    super.key,
    this.labelText,
    this.helperText,
    this.errorText,
    this.hintText = '',
    this.inputFormatters,
    this.textInputType,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearTextButton = true,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.isDense,
    this.verticalPadding = 8,
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

  /// An optional list of [TextInputFormatter] to apply to the input field.
  final List<TextInputFormatter>? inputFormatters;

  /// An optional [TextInputType] to specify the type of keyboard to display.
  final TextInputType? textInputType;

  /// An optional [Widget] to display as a prefix icon inside the input field.
  final Widget? prefixIcon;

  /// An optional [Widget] to display as a suffix icon inside the input field.
  final Widget? suffixIcon;

  /// A boolean to determine if a clear text button should be shown when the
  /// input field is focused and contains text. Defaults to `true`.
  final bool showClearTextButton;

  /// A boolean to determine if the input field is enabled. Defaults to `true`.
  final bool enabled;

  /// A boolean to determine if the input field is read-only.
  /// Defaults to `false`.
  final bool readOnly;

  /// An optional integer to specify the maximum number of lines for the
  /// input field. Defaults to `1`.
  final int? maxLines;

  /// An optional boolean to determine if the input field should be dense.
  final bool? isDense;

  /// An optional double to determine the vertical padding of the input field. 
  /// Defaults to `8`.
  final double verticalPadding;

  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Focus(
        child: Builder(
          builder: (context) {
            return TextField(
              maxLines: maxLines,
              readOnly: readOnly,
              enabled: enabled,
              controller: controller,
              decoration: InputDecoration(
                isDense: isDense,
                label: labelText != null
                    ? Text(
                        labelText!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                helperText: Focus.of(context).hasFocus &&
                        helperText != null &&
                        !readOnly
                    ? helperText
                    : null,
                helperMaxLines: defaultHelperMaxLines,
                errorText: errorText,
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                prefixIcon: prefixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                suffixIcon: suffixIcon ??
                    (Focus.of(context).hasFocus &&
                            controller.text.isNotEmpty &&
                            showClearTextButton &&
                            !readOnly
                        ? IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: controller.clear,
                          )
                        : null),
              ),
              inputFormatters: inputFormatters,
              keyboardType: textInputType,
            );
          },
        ),
      ),
    );
  }
}
