import 'package:avatar_brick/avatar_brick.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/ui/widgets/horizontal_list.dart';
import 'package:chat/src/ui/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget(this.message, {super.key});

  final Message message;
  static const avatarPadding = EdgeInsets.only(top: 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: message.role == Role.user
          ? Theme.of(context).colorScheme.background
          : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: avatarPadding,
            child: message.role == Role.user
                ? const AvatarBrick(
                    size: Size(32, 32),
                    backgroundColor: Colors.black26,
                    icon: Icon(
                      Icons.person_2_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  )
                : const AvatarBrick(
                    size: Size(32, 32),
                    backgroundColor: Colors.black26,
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(
            width: 8,
          ), // Add spacing between the leading widget and title
          if (message.status == Status.sending)
            const Padding(
              padding: avatarPadding,
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
                    child: MarkdownWidget(message.text),
                  ),
                  HorizontalList(message.embeddings),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
