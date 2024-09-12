import 'package:flutter/material.dart';

class CheckboxOrSwitchListTile extends StatelessWidget {
  const CheckboxOrSwitchListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.screenWidthBreakpoint = 600,
    this.controlAffinity = ListTileControlAffinity.platform,
    super.key,
  });

  final Widget title;
  final bool value;
  final ListTileControlAffinity controlAffinity;
  final ValueChanged<bool> onChanged;
  final double screenWidthBreakpoint;

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine widget type based on screen width
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
