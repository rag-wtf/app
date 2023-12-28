import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:flutter/material.dart';

class DocumentProgressIndicatorWidget extends StatelessWidget {
  const DocumentProgressIndicatorWidget(
    this.status, {
    this.progress,
    super.key,
  });
  final DocumentStatus status;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    Widget uploadProgressIndicator;
    if (status == DocumentStatus.uploading) {
      uploadProgressIndicator = LinearProgressIndicator(
        value: progress,
        semanticsLabel: uploadProgressSemanticsLabel,
      );
    } else if (status == DocumentStatus.indexing) {
      uploadProgressIndicator = const LinearProgressIndicator(
        semanticsLabel: processProgressSemanticsLabel,
      );
    } else {
      uploadProgressIndicator = const SizedBox.shrink();
    }
    return uploadProgressIndicator;
  }
}
