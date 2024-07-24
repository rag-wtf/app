import 'package:dio/dio.dart';
import 'package:document/src/services/document.dart';

class DocumentItem {
  DocumentItem(
    this.tablePrefix,
    this.item, [
    this.progress,
    this.cancelToken,
  ]);

  String tablePrefix;
  Document item;
  double? progress;
  final CancelToken? cancelToken;
}
