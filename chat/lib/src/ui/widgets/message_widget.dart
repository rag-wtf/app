import 'package:avatar_brick/avatar_brick.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/ui/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';

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
              size: Size(32, 32),
              backgroundColor: Colors.black26,
              icon: Icon(
                Icons.person_2_outlined,
                size: 24,
                color: Colors.white,
              ),
            )
          else
            const AvatarBrick(
              size: Size(32, 32),
              backgroundColor: Colors.black26,
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          const SizedBox(
            width: 8,
          ), // Add spacing between the leading widget and title
          if (message.type == MessageType.loading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(),
            )
          else
            Expanded(child: MarkdownWidget(message.text)),
        ],
      ),
    );
  }
}
