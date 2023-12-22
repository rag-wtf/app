import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:mime_type/mime_type.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';
import 'package:retry/retry.dart';
import 'constants.dart';

class UploadFileList {
  final List<UploadFile> items = [];
  late UploadFileService _uploadFileService;

  UploadFileList(
      {required String dataIngestionApiUrl,
      required String embeddingsApiUrl,
      required String embeddingsApiKey,
      required Surreal surreal}) {
    _uploadFileService = UploadFileService(
      dataIngestionApiUrl: dataIngestionApiUrl,
      embeddingsApiUrl: embeddingsApiUrl,
      embeddingsApiKey: embeddingsApiKey,
      db: surreal,
    );
  }

  Future<void> add() async {
    final item = await _uploadFileService.pickFile();
    if (item != null) {
      items.add(item);
      _uploadFileService.upload(item);
    }
  }
}

enum UploadFileStatus {
  pending,
  uploading,
  processing,
  completed,
  failed,
  cancelled,
}

class UploadFile extends ChangeNotifier {
  final String name;
  final int size;
  final MediaType contentType;
  final List<List<int>> data;
  UploadFileStatus status = UploadFileStatus.pending;
  double _uploadingProgress = 0;
  double _processingProgress = 0;
  DateTime? dateTime;
  CancelToken? _cancelToken;
  String? errorMessage;

  UploadFile(
    this.name,
    this.size,
    this.contentType,
    this.data,
  );

  double get uploadingProgress => _uploadingProgress;

  set uploadingProgress(double progress) {
    if (progress > 0.0) {
      status = UploadFileStatus.uploading;
    }
    _uploadingProgress = progress;
    notifyListeners();
  }

  double get processingProgress => _processingProgress;

  set processingProgress(double progress) {
    if (progress > 0.0) {
      status = UploadFileStatus.processing;
    }

    _processingProgress = progress;
    notifyListeners();
  }

  void cancel() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken?.cancel();
    }
  }

  void updateStatus(UploadFileStatus newStatus, DateTime newDateTime) {
    status = newStatus;
    dateTime = newDateTime;
    notifyListeners();
  }
}

class UploadFileService {
  UploadFileService(
      {required this.dataIngestionApiUrl,
      required this.embeddingsApiUrl,
      required this.embeddingsApiKey,
      required Surreal db}) {
    documentService = DocumentService(db: db);
  }

  final String dataIngestionApiUrl;
  final String embeddingsApiUrl;
  final String embeddingsApiKey;

  late DocumentService documentService;

  final gzipEncoder = GZipEncoder();
  final gzipDecoder = GZipDecoder();

  Future<List> sendInBatches(
    Dio dio,
    List<String> chunkedTexts, {
    int batchSize = 10,
  }) async {
    // Calculate the number of batches
    int numBatches = (chunkedTexts.length / batchSize).ceil();
    final embeddings = [];

    for (var i = 0; i < numBatches; i++) {
      // Get the start and end indices of the current batch
      int start = i * batchSize;
      int end = start + batchSize;

      debugPrint('start $start, end $end');

      // Get the current batch of texts
      List<String> batch =
          chunkedTexts.sublist(start, min(end, chunkedTexts.length));

      // Send the batch and add the future to the list
      final response = await retry(
        () => dio.post(
          embeddingsApiUrl,
          options: Options(
            headers: {
              'Content-type': 'application/json',
              if (embeddingsApiKey.isNotEmpty)
                'Authorization': 'Bearer $embeddingsApiKey',
            },
            requestEncoder: gzipRequestEncoder,
          ),
          data: {
            'input': batch,
          },
        ).then((response) {
          debugPrint('Batch ${i + 1} sent successfully');
          return response;
        }),
        retryIf: (e) =>
            e is DioException &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      ).catchError(
        (e) {
          debugPrint('Failed to send batch ${i + 1}: $e');
          throw e;
        },
      );

      final embeddingsDataMap = Map<String, dynamic>.from(response.data);
      embeddings.addAll(
        List.from(
          embeddingsDataMap['data'],
        ),
      );
      Future.delayed(const Duration(seconds: 1));
    }

    debugPrint('sendInBatches: embeddings.length = ${embeddings.length}');

    return embeddings;
  }

  bool isGzFile(final fileBytes) {
    return (fileBytes[0] == 0x1f && fileBytes[1] == 0x8b);
  }

  // gzip request
  List<int> gzipRequestEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return gzipEncoder.encode(utf8.encode(request))!;
  }

  Future<String> compressFileToBase64(List<int> bytes) async {
    if (isGzFile(bytes)) {
      return base64Encode(bytes);
    } else {
      return base64Encode(
        gzipEncoder.encode(bytes)!,
      );
    }
  }

  Future<List<int>> decompressFileFromBase64(String file) async {
    final bytes = base64Decode(file);
    return isGzFile(bytes) ? gzipDecoder.decodeBytes(bytes) : bytes;
  }

  Future<UploadFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions.split(","),
      allowMultiple: false,
      withData: false,
      withReadStream: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    PlatformFile file = result.files.first;
    String? mimeType;
    String fileName = unknownFileName;
    if (kIsWeb) {
      // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-i-access-the-path-on-web
      final fileBytes =
          file.bytes; // Even withData: true, always null in web platform
      fileName = file.name;
      mimeType = lookupMimeType(fileName, headerBytes: fileBytes);
    } else {
      final filePath = file.path;
      if (filePath != null) {
        mimeType = lookupMimeType(filePath);
        fileName = filePath.split(Platform.pathSeparator).last;
      }
    }

    mimeType ??= mime(fileName);
    debugPrint("fileName $fileName, mimeType $mimeType");

    final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

    // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-do-i-use-withreadstream
    final fileReadStream = file.readStream;
    if (fileReadStream == null) {
      throw Exception(fileStreamExceptionMessage);
    }

    // Buffer the stream so that it can be process multiple times
    final fileData = await fileReadStream.toList();

    return UploadFile(
      fileName,
      file.size,
      contentType!,
      fileData,
    );
  }

  Future<String> convertStreamToString(Stream<List<int>> stream) async {
    final StringBuffer buffer = StringBuffer();
    await stream.transform(utf8.decoder).forEach(buffer.write);
    debugPrint('buffer $buffer');
    return buffer.toString();
  }

  void upload(UploadFile file) async {
    final dio = Dio();
    final cancelToken = CancelToken();
    file._cancelToken = cancelToken;
    Map<String, dynamic>? documentMap;

    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(file.data),
      file.size,
      filename: file.name,
      contentType: file.contentType,
    );

    final formData = FormData.fromMap({
      "file": multipartFile,
    });
    //const vpsIngestionApiUrl = 'http://199.181.238.6:8000/ingest';
    debugPrint('dataIngestionApiUrl $dataIngestionApiUrl');
    dio.post(
      dataIngestionApiUrl,
      /*options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
          'Access-Control-Allow-Methods': 'POST',
        },
      ),*/
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (int sent, int total) {
        double progress = sent / total;
        file.uploadingProgress = progress;
      },
      onReceiveProgress: (int count, int total) {
        debugPrint("onReceiveProgress(count: $count, total: $total)");
        double progress = count * 0.01;
        file.processingProgress = progress;
      },
    ).then((response) async {
      // Handle the response data in here
      //debugPrint("RESPONSE FROM SERVER ${response.headers}");
      //debugPrint("response.data.runtimeType ${response.data.runtimeType}");
      //debugPrint("/ingest ${response.data}");
      documentMap = Map<String, dynamic>.from(response.data);
      final documentItems =
          List<Map<String, dynamic>>.from(documentMap?['items']);
      if (documentItems.isEmpty) {
        documentItems.add({
          'content': await convertStreamToString(Stream.fromIterable(file.data))
        });
      }
      final chunkedTexts = List<String>.from(
        documentItems.map((item) => item['content']).toList(),
      );
      debugPrint('chunkedTexts ${chunkedTexts.length}');
      debugPrint('chunkedTexts[0] ${chunkedTexts[0]}');

      final embeddingsData = await sendInBatches(
        dio,
        chunkedTexts,
        batchSize: 10,
      );

      /*     final embeddingsResponse = await dio.post(
        '$embeddingsApiBase/embeddings',
        options: Options(
          headers: {
            'Content-type': 'application/json',
            if (embeddingsApiKey.isNotEmpty)
              'Authorization': 'Bearer $embeddingsApiKey',
          },
          requestEncoder: gzipRequestEncoder,
        ),
        data: {
          'input': chunkedTexts,
        },
      );*/
      try {
        final embeddings = List.generate(
          documentItems.length,
          (index) {
            final documentItem = documentItems[index];
            return Embedding(
              id: 'Embedding:${Ulid()}',
              content: documentItem['content'],
              embedding: List<double>.from(embeddingsData[index]['embedding']),
              metadata: documentItem['metadata'] ?? {},
              tokensCount: documentItem['tokens_count'] ?? 0,
            );
          },
        );
        documentMap?['embeddings'] = embeddings;
      } catch (e, s) {
        debugPrint("ERROR: $e");
        debugPrintStack(label: "STACKTRACE", maxFrames: 10, stackTrace: s);
      }
      //debugPrint("document ${jsonEncode(documentMap)}");
    }).catchError((error) {
      // Handle the error in here
      if (error is DioException) {
        // Here's an example of how you might handle different error types
        switch (error.type) {
          case DioExceptionType.cancel:
            debugPrint("Request to API was cancelled");
            file.updateStatus(UploadFileStatus.cancelled, DateTime.now());
            break;
          default:
            debugPrint("*** DioException ERROR $error");
            // TODO: the error may cause by no response streaming support in AWS Lambda,
            // Self hosting need not to perform the conditional check
            if (error.message != null) {
              file.errorMessage = error.message;
              file.updateStatus(UploadFileStatus.failed, DateTime.now());
            }
        }
      } else {
        debugPrint("*** Other ERROR $error");
        file.errorMessage = error.toString();
        file.updateStatus(UploadFileStatus.failed, DateTime.now());
      }
    }).whenComplete(() async {
      // Any cleanup code goes here
      debugPrint('Request completed');
      if (file.status != UploadFileStatus.failed &&
          file.status != UploadFileStatus.cancelled) {
        file.updateStatus(UploadFileStatus.completed, DateTime.now());
      }
      String base64EncodedFile = await compressFileToBase64(
        file.data.first,
      );
      final document = Document(
        id: 'Document:${Ulid()}',
        content: documentMap?['content'],
        tokensCount: documentMap?['tokens_count'] ?? 0,
        compressedFileSize: base64EncodedFile.length,
        fileMimeType: file.contentType.mimeType,
        contentMimeType: documentMap?['mime_type'],
        created: DateTime.now(),
        errorMessage: file.errorMessage,
        name: file.name,
        originFileSize: file.size,
        status: file.status.toString(),
        file: base64EncodedFile,
      );
      if (!await documentService.isSchemaCreated()) {
        await documentService.createSchema();
      }
      final result = await documentService.createDocumentEmbeddings(
        document,
        documentMap?['embeddings'],
      );
      assert(result != null);
      //debugPrint('result $result');
    });
  }
}
