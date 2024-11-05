import 'package:document/src/services/document.dart';
import 'package:flutter/material.dart';

class DocumentStatusWidget extends StatelessWidget {
  const DocumentStatusWidget({
    required this.item,
    super.key,
  });

  final Document item;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Widget status;
    switch (item.status) {
      case DocumentStatus.completed:
        textColor = Colors.green;

      case DocumentStatus.canceled:
        textColor = Colors.orange;

      case DocumentStatus.failed:
        textColor = Colors.red;

      case DocumentStatus.created:
      case DocumentStatus.pending:
      case DocumentStatus.splitting:
      case DocumentStatus.indexing:
        textColor = Colors.grey;
    }

    if (item.status == DocumentStatus.failed && item.errorMessage != null) {
      status = Tooltip(
        message: item.errorMessage,
        child: Row(
          children: [
            Text(
              item.status.name,
              style: TextStyle(
                color: textColor,
              ),
            ),
            Icon(
              Icons.error_outline,
              size: 16,
              color: textColor,
            ),
          ],
        ),
      );
    } else {
      status = Text(
        item.status.name,
        style: TextStyle(
          color: textColor,
        ),
      );
    }
    return status;
  }
}
