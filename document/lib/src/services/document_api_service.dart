import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:http_parser/http_parser.dart';

class DocumentApiService {
  final _gzipEncoder = locator<GZipEncoder>();

  final _log = getLogger('DocumentApiService');

  Future<void> split(
    Dio dio,
    String url,
    DocumentItem documentItem,
    Future<void> Function(
      DocumentItem documentItem,
      DocumentStatus status,
    ) onUpdateDocumentStatus,
    void Function(
      DocumentItem documentItem,
      double progress,
    ) onProgress,
    Future<void> Function(
      DocumentItem documentItem,
      Map<String, dynamic>? responseData,
    ) onSplitCompleted,
    // ignore: prefer_void_to_null
    Future<Null> Function(DocumentItem documentItem, dynamic error) onError,
  ) async {
    final bytesLength = documentItem.item.byteData![0].length;
    _log.d('bytesLength $bytesLength');
    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(documentItem.item.byteData!),
      documentItem.item.byteData!.length,
      filename: documentItem.item.name,
      contentType: MediaType.parse(documentItem.item.fileMimeType),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    await dio.post<Map<String, dynamic>>(
      url,
      data: formData,
      cancelToken: documentItem.cancelToken,
      onSendProgress: (int sent, int total) async {
        if (documentItem.item.status == DocumentStatus.pending) {
          _log.d('updateDocumentStatus(DocumentStatus.splitting)');
          await onUpdateDocumentStatus(documentItem, DocumentStatus.splitting);
        }

        final progress = sent / total;
        onProgress(documentItem, progress);
      },
      onReceiveProgress: (int count, int total) async {
        /* The same code above works but not the following code?
        if (total == 0 && widgetModel.item.status == DocumentStatus.pending) {
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }
        */
        final progress = count * 0.01;
        onProgress(documentItem, progress);
      },
    ).then((response) async {
      await onSplitCompleted(documentItem, response.data).timeout(
        Duration(milliseconds: max(bytesLength * 3, 600 * 1000)),
      );
    }).catchError((dynamic error) {
      onError(documentItem, error);
    }).timeout(
      Duration(milliseconds: max(bytesLength * 3, 600 * 1000)),
    );
  }

  Future<List<TResult>> executeInBatch<TInput, TResult>(
    List<TInput> values,
    int batchSize,
    Future<List<TResult>> Function(
      List<TInput> values,
    ) batchFunction,
  ) async {
    final numBatches = (values.length / batchSize).ceil();
    final items = List<TResult>.empty(growable: true);

    for (var i = 0; i < numBatches; i++) {
      // Get the start and end indices of the current batch
      final start = i * batchSize;
      final end = start + batchSize;

      _log.d('start $start, end $end');

      // Get the current batch of items
      final batch = values.sublist(
        start,
        min(end, values.length),
      );
      items.addAll(await batchFunction(batch));
    }

    return items;
  }

  Future<List<List<double>>> index(
    Dio dio,
    String model,
    String apiUrl,
    String apiKey,
    List<String> chunkedTexts, {
    int dimensions = 384,
    int batchSize = 100,
  }) async {
    final embeddings = await executeInBatch<String, List<double>>(
      chunkedTexts,
      batchSize,
      (values) async {
        // Send the batch and add the future to the list
        final response = await dio.post<Map<String, dynamic>>(
          apiUrl,
          options: Options(
            headers: {
              'Content-type': 'application/json',
              if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
            },
            requestEncoder: gzipRequestEncoder,
            sendTimeout: const Duration(seconds: 600),
            receiveTimeout: const Duration(seconds: 600),
          ),
          data: {
            'model': model,
            'input': values,
          },
        );

        final embeddingsDataMap = response.data;
        return List<Map<String, dynamic>>.from(
          embeddingsDataMap?['data'] as List,
        )
            .map(
              (item) => List<double>.from(
                item['embedding'] as List,
              ),
            )
            .toList();
      },
    );

    _log.d('embeddings.length = ${embeddings.length}');

    return embeddings;
  }

  List<int> gzipRequestEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }
}
