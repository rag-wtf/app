import 'package:flutter/material.dart';

class PromptWidget extends StatelessWidget {
  const PromptWidget(
    this.text, {
    required this.onSend,
    this.width = 120,
    this.height = 80,
    super.key,
  });
  final String text;
  final double width;
  final double height;
  final void Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => onSend(text),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}
