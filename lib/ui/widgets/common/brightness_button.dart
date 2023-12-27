import 'package:flutter/material.dart';
import 'package:stacked_themes/stacked_themes.dart';

class BrightnessButton extends StatelessWidget {
  const BrightnessButton({
    super.key,
    this.showTooltipBelow = true,
  });

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
        onPressed: () {
          getThemeManager(context).toggleDarkLightTheme();
        },
      ),
    );
  }
}
