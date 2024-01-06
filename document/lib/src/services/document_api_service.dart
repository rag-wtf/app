import 'dart:convert';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widgetmodel.dart';
import 'package:http_parser/http_parser.dart';

class DocumentApiService {
  final _gzipEncoder = locator<GZipEncoder>();
  final _log = getLogger('ApiService');

  void split(
    Dio dio,
    String url,
    DocumentItemWidgetModel widgetModel,
  ) {
    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(widgetModel.item.byteData!),
      widgetModel.item.byteData!.length,
      filename: widgetModel.item.name,
      contentType: MediaType.parse(widgetModel.item.fileMimeType),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    dio.post<Map<String, dynamic>>(
      url,
      data: formData,
      cancelToken: widgetModel.cancelToken,
      onSendProgress: (int sent, int total) async {
        if (widgetModel.item.status == DocumentStatus.pending) {
          _log.d('updateDocumentStatus(DocumentStatus.splitting)');
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }

        final progress = sent / total;
        widgetModel.progress = progress;
      },
      onReceiveProgress: (int count, int total) async {
        /* The same code above works but not the following code?
        if (total == 0 && widgetModel.item.status == DocumentStatus.pending) {
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }
        */
        final progress = count * 0.01;
        widgetModel.progress = progress;
      },
    ).then((response) async {
      await widgetModel.onSplitCompleted(response.data);
    }).catchError(
      widgetModel.onError,
    );
  }

  Future<List<List<double>>> index(
    Dio dio,
    String apiUrl,
    String apiKey,
    List<String> chunkedTexts, {
    int batchSize = 100,
  }) async {
    // Calculate the number of batches
    final numBatches = (chunkedTexts.length / batchSize).ceil();
    final embeddings = <List<double>>[];

    for (var i = 0; i < numBatches; i++) {
      // Get the start and end indices of the current batch
      final start = i * batchSize;
      final end = start + batchSize;

      _log.d('start $start, end $end');

      // Get the current batch of texts
      final batch = chunkedTexts.sublist(start, min(end, chunkedTexts.length));

      // Send the batch and add the future to the list
      final response = await dio.post<Map<String, dynamic>>(
        apiUrl,
        options: Options(
          headers: {
            'Content-type': 'application/json',
            if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
          },
          requestEncoder: gzipRequestEncoder,
        ),
        data: {
          'input': batch,
        },
      );

      final embeddingsDataMap = response.data;
      embeddings.addAll(
        List<Map<String, dynamic>>.from(
          embeddingsDataMap?['data'] as List,
        )
            .map(
              (item) => List<double>.from(
                item['embedding'] as List,
              ),
            )
            .toList(),
      );
    }

    _log.d('embeddings.length = ${embeddings.length}');

    return embeddings;
  }

  List<int> gzipRequestEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }
}
