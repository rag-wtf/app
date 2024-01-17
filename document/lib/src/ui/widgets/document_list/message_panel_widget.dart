import 'package:flutter/material.dart';

class MessagePanelWidget extends StatelessWidget {

  const MessagePanelWidget({required this.message, super.key, this.icon});
  final Icon? icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add a subtle shadow
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: icon,
              ),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
