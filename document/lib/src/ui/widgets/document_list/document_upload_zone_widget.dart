import 'package:flutter/material.dart';

class DocumentUploadZoneWidget extends StatelessWidget {
  const DocumentUploadZoneWidget({
    required this.message,
    required this.onTap,
    super.key,
    this.icon,
  });
  final Icon? icon;
  final String message;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: icon,
                ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
