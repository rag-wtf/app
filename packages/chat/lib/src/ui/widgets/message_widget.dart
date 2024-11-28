import 'package:avatar_brick/avatar_brick.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/ui/widgets/horizontal_list.dart';
import 'package:chat/src/ui/widgets/markdown_widget.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:ui/ui.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget(this.message, this.showDialogFunction, {super.key});

  final Message message;
  final Future<void> Function(Embedding embedding) showDialogFunction;
  static const avatarPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final foregroundColor =
        brightness == Brightness.dark ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: avatarPadding),
              child: message.role == Role.user
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle, // Make the container circular
                      ),
                      child: Icon(
                        Icons.person_2_outlined,
                        size: 24,
                        color: foregroundColor,
                      ),
                    )
                  : const Logo(
                      darkLogo: darkLogo,
                      lightLogo: lightLogo,
                      size: 32,
                    )),
          const SizedBox(
            width: 8,
          ), // Add spacing between the leading widget and title
          if (message.status == Status.sending)
            const Padding(
              padding: EdgeInsets.only(top: avatarPadding + 5.0),
              child: SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: MarkdownWidget(message.value.content),
                  ),
                  HorizontalList(message.embeddings, showDialogFunction),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
