import 'package:flutter/material.dart';

class BrightnessButton extends StatelessWidget {
  const BrightnessButton({
    required this.handleThemeModeChange,
    super.key,
    this.showTooltipBelow = true,
  });

  final void Function({required bool useLightMode}) handleThemeModeChange;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: isBright
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () => handleThemeModeChange(useLightMode: !isBright),
      ),
    );
  }
}
