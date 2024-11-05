import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/ui/widgets/document_list/cancel_button_widget.dart';
import 'package:flutter/material.dart';

class DocumentProgressIndicatorWidget extends StatelessWidget {
  const DocumentProgressIndicatorWidget(
    this.documentItem, {
    this.progress,
    super.key,
  });

  final DocumentItem documentItem;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    Widget uploadProgressIndicator;
    if (documentItem.item.status == DocumentStatus.splitting) {
      final linearProgressIndicator = LinearProgressIndicator(
        value: progress,
        semanticsLabel: uploadProgressSemanticsLabel,
      );
      if (documentItem.cancelToken == null) {
        uploadProgressIndicator = linearProgressIndicator;
      } else {
        uploadProgressIndicator = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: linearProgressIndicator),
            CancelButtonWidget(documentItem.cancelToken!),
          ],
        );
      }
    } else if (documentItem.item.status == DocumentStatus.indexing) {
      uploadProgressIndicator = const LinearProgressIndicator(
        semanticsLabel: processProgressSemanticsLabel,
      );
    } else {
      uploadProgressIndicator = const SizedBox.shrink();
    }
    return uploadProgressIndicator;
  }
}
