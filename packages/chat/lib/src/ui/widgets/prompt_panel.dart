import 'dart:math';

import 'package:chat/src/ui/common/ui_helpers.dart';
import 'package:chat/src/ui/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:ui/ui.dart';

class PromptPanel extends StatelessWidget {
  PromptPanel(this.onSend, {super.key});
  final prompts = const String.fromEnvironment(promptsKey).split(',');
  final void Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    prompts.shuffle(Random());
    final selectedPrompts = prompts.take(4).toList();
    if (width >= 1180) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Logo(
            darkLogo: darkLogo,
            lightLogo: lightLogo,
            size: 64,
          ),
          verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: selectedPrompts
                .map(
                  (prompt) => PromptWidget(prompt, onSend: onSend),
                )
                .toList(),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Logo(
                darkLogo: darkLogo,
                lightLogo: lightLogo,
                size: 64,
              ),
              verticalSpaceMedium,
              Row(
                children: [
                  PromptWidget(selectedPrompts[0], onSend: onSend),
                  PromptWidget(selectedPrompts[1], onSend: onSend),
                ],
              ),
              Row(
                children: [
                  PromptWidget(selectedPrompts[2], onSend: onSend),
                  PromptWidget(selectedPrompts[3], onSend: onSend),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }
}
