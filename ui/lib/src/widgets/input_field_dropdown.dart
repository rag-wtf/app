import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/widgets/input_field.dart';

/// A customizable dropdown input field widget for Flutter.
///
/// This widget extends [StatelessWidget] and provides a dropdown input field
/// that can be used to select an item from a list. It integrates with the
/// [InputField] widget to provide a consistent look and feel for input fields
/// in your application.
///
/// ## Features
/// - Customizable hint text, label text, and error text.
/// - Support for prefix and suffix icons.
/// - Loading state with customizable loading text.
/// - Ability to specify default value and maximum dropdown height.
/// - Callbacks for dropdown open/close events and item selection.
/// - Support for text input formatters and keyboard types.
/// - Option to show a clear text button.
///
/// ## Example Usage
/// ```dart
/// InputFieldDropdown<String>(
///   controller: TextEditingController(),
///   labelText: 'Select an option',
///   items: ['Option 1', 'Option 2', 'Option 3'],
///   getItemDisplayText: (String item) => item,
///   onSelected: (String selected) {
///     print('Selected: $selected');
///   },
/// )
/// ```
///
/// ## Parameters
/// - **isDense**: Whether the input field should be dense. Defaults to `false`.
/// - **hintText**: The hint text to display when the input is empty.
/// - **labelText**: The label text to display above the input field.
/// - **controller**: The [TextEditingController] for the input field. Required.
/// - **errorText**: The error text to display when the input is invalid.
/// - **suffixIcon**: The icon to display at the end of the input field.
///                   Defaults to [Icons.arrow_drop_down].
/// - **items**: The list of items to display in the dropdown.
/// - **getItemValue**: A function that returns the value of an item.
/// - **getItemDisplayText**: A function that returns the display text of
///                           an item.
/// - **onSelected**: A callback function that is called when
///                   an item is selected.
/// - **dropdownTextStyle**: The text style for the dropdown items.
/// - **inputTextStyle**: The text style for the input field.
/// - **isLoading**: Whether the dropdown is in a loading state.
///                  Defaults to `false`.
/// - **loadingText**: The text to display when the dropdown is in
///                    a loading state. Defaults to 'Loading...'.
/// - **defaultValue**: The default value to display in the input field.
/// - **enabled**: Whether the input field is enabled. Defaults to `true`.
/// - **readOnly**: Whether the input field is read-only. Defaults to `false`.
/// - **prefixIcon**: The icon to display at the start of the input field.
/// - **focusNode**: The [FocusNode] for the input field.
/// - **onDropdownOpened**: A callback function that is called
///                         when the dropdown is opened.
/// - **onDropdownClosed**: A callback function that is called
///                         when the dropdown is closed.
/// - **dropdownMaxHeight**: The maximum height of the dropdown.
///                          Defaults to `300.0`.
/// - **showClearTextButton**: Whether to show a clear text button.
///                            Defaults to `false`.
/// - **inputFormatters**: A list of [TextInputFormatter] to apply to the
///                        input field.
/// - **textInputType**: The type of keyboard to display for the input field.
/// - **maxLines**: The maximum number of lines for the input field.
///                 Defaults to `1`.
///
/// ## Dependencies
/// This widget depends on the following packages:
/// - `flutter/material.dart`
/// - `flutter/services.dart`
/// - `ui/src/widgets/input_field.dart`
///
/// ## See Also
/// - [InputField]: The base input field widget used by this dropdown.
/// - [PopupMenuButton]: The dropdown menu widget used to display the items.
/// - [TextEditingController]: The controller for the input field.
/// - [TextInputFormatter]: The formatter for the input field.
/// - [FocusNode]: The focus node for the input field.
///
class InputFieldDropdown<T> extends StatelessWidget {
  /// Creates a [InputFieldDropdown] widget.
  ///
  /// The [controller] is required and must not be null.
  ///
  /// The [isDense], [isLoading], [enabled], and [readOnly] parameters
  /// are optional and default to `false`, `false`, `true`,
  /// and `false` respectively.
  ///
  /// The [suffixIcon] defaults to [Icons.arrow_drop_down].
  ///
  /// The [dropdownMaxHeight] defaults to `300.0`.
  ///
  /// The [maxLines] defaults to `1`.
  ///
  /// The [loadingText] defaults to 'Loading...'.
  ///
  /// The [showClearTextButton] defaults to `false`.
  const InputFieldDropdown({
    required this.controller,
    super.key,
    this.isDense = false,
    this.hintText,
    this.labelText,
    this.errorText,
    this.suffixIcon = Icons.arrow_drop_down,
    this.items,
    this.getItemValue,
    this.getItemDisplayText,
    this.onSelected,
    this.dropdownTextStyle,
    this.inputTextStyle,
    this.isLoading = false,
    this.loadingText = 'Loading...',
    this.defaultValue,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.focusNode,
    this.onDropdownOpened,
    this.onDropdownClosed,
    this.dropdownMaxHeight = 300.0,
    this.showClearTextButton = false,
    this.inputFormatters,
    this.textInputType,
    this.maxLines = 1,
  });

  /// Whether the input field should be dense.
  final bool isDense;

  /// The hint text to display when the input is empty.
  final String? hintText;

  /// The label text to display above the input field.
  final String? labelText;

  /// The controller for the input field. Required.
  final TextEditingController controller;

  /// The error text to display when the input is invalid.
  final String? errorText;

  /// The icon to display at the end of the input field.
  /// Defaults to [Icons.arrow_drop_down].
  final IconData suffixIcon;

  /// The list of items to display in the dropdown.
  final List<T>? items;

  /// A function that returns the value of an item.
  final String Function(T)? getItemValue;

  /// A function that returns the display text of an item.
  final String Function(T)? getItemDisplayText;

  /// A callback function that is called when an item is selected.
  final void Function(T)? onSelected;

  /// The text style for the dropdown items.
  final TextStyle? dropdownTextStyle;

  /// The text style for the input field.
  final TextStyle? inputTextStyle;

  /// Whether the dropdown is in a loading state. Defaults to `false`.
  final bool isLoading;

  /// The text to display when the dropdown is in a loading state.
  /// Defaults to 'Loading...'.
  final String? loadingText;

  /// The default value to display in the input field.
  final T? defaultValue;

  /// Whether the input field is enabled. Defaults to `true`.
  final bool enabled;

  /// Whether the input field is read-only. Defaults to `false`.
  final bool readOnly;

  /// The icon to display at the start of the input field.
  final Widget? prefixIcon;

  /// The focus node for the input field.
  final FocusNode? focusNode;

  /// A callback function that is called when the dropdown is opened.
  final VoidCallback? onDropdownOpened;

  /// A callback function that is called when the dropdown is closed.
  final VoidCallback? onDropdownClosed;

  /// The maximum height of the dropdown. Defaults to `300.0`.
  final double dropdownMaxHeight;

  /// Whether to show a clear text button. Defaults to `false`.
  final bool showClearTextButton;

  /// A list of [TextInputFormatter] to apply to the input field.
  final List<TextInputFormatter>? inputFormatters;

  /// The type of keyboard to display for the input field.
  final TextInputType? textInputType;

  /// The maximum number of lines for the input field. Defaults to `1`.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return InputField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      isDense: isDense,
      prefixIcon: prefixIcon,
      suffixIcon: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : PopupMenuButton<T>(
              icon: Icon(suffixIcon),
              onOpened: onDropdownOpened,
              onCanceled: onDropdownClosed,
              onSelected: onSelected,
              itemBuilder: (BuildContext context) {
                if (items == null || items!.isEmpty) {
                  return [
                    const PopupMenuItem(
                      enabled: false,
                      child: Text('No options available'),
                    ),
                  ];
                }
                return items!.map((T item) {
                  return PopupMenuItem<T>(
                    value: item,
                    child: Text(
                      getItemDisplayText?.call(item) ?? '',
                      style: dropdownTextStyle ??
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }).toList();
              },
              constraints: BoxConstraints(maxHeight: dropdownMaxHeight),
              initialValue: defaultValue,
            ),
      showClearTextButton: showClearTextButton,
      enabled: enabled && !isLoading,
      readOnly: readOnly,
      textInputType: textInputType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }
}
