import 'package:avatar_brick/avatar_brick.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/ui/widgets/code_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      //color: chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.role == Role.user)
            const AvatarBrick(
              backgroundColor: Colors.black26,
              icon: Icon(
                Icons.person_rounded,
                size: 32,
                color: Colors.white,
              ),
            )
          else
            const AvatarBrick(
              backgroundColor: Colors.black26,
              icon: Icon(
                Icons.computer_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          const SizedBox(
            width: 5,
          ), // Add spacing between the leading widget and title

          Expanded(child: buildMarkdown(context)),
        ],
      ),
    );
  }

  Widget buildMarkdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    const codeWrapper = CodeWrapperWidget.new;
    return MarkdownBlock(
      data: message.text,
      config: config.copy(
        configs: [
          if (isDark)
            PreConfig.darkConfig.copy(wrapper: codeWrapper)
          else
            const PreConfig().copy(wrapper: codeWrapper),
        ],
      ),
    );
  }
}
