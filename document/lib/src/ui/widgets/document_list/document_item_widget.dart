import 'package:document/src/services/document.dart';
import 'package:document/src/ui/widgets/document_list/cancel_button_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_progress_indicator_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_status_widget.dart';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';

class DocumentItemWidget extends StatelessWidget {
  const DocumentItemWidget(this.item, {super.key});
  static int megaBytes = 1024 * 1024;
  final Document item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FileIcon(
                  item.name,
                  size: 64,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ), // Add some spacing between title and subtitle
                      Row(
                        children: [
                          Text(
                            '${(item.originFileSize / megaBytes).toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: DocumentProgressIndicatorWidget(
                                    item.status,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DocumentStatusWidget(item: item),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //const CancelButtonWidget(),
        ],
      ),
    );
  }
}
