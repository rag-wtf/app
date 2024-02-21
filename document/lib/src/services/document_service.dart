import 'dart:convert';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

class DocumentService with ListenableServiceMixin {
  DocumentService() {
    listenToReactiveValues([_items]);
  }
  final _dio = locator<Dio>();
  final _db = locator<Surreal>();
  final _documentRepository = locator<DocumentRepository>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();
  final _apiService = locator<DocumentApiService>();
  final _settingService = locator<SettingService>();
  final _gzipEncoder = locator<GZipEncoder>();
  final _gzipDecoder = locator<GZipDecoder>();

  int _total = -1;
  final _items = <DocumentItem>[];
  List<DocumentItem> get items => _items.toList();

  final _log = getLogger('DocumentService');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Document.tableName}') &&
        tables.containsKey('${tablePrefix}_${Embedding.tableName}') &&
        tables.containsKey('${tablePrefix}_${DocumentEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await _db.transaction(
        (txn) async {
          await _documentRepository.createSchema(tablePrefix, txn);
          await _embeddingRepository.createSchema(tablePrefix, txn);
          await _documentEmbeddingRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await _documentRepository.createSchema(tablePrefix, txn);
      await _embeddingRepository.createSchema(tablePrefix, txn);
      await _documentEmbeddingRepository.createSchema(tablePrefix, txn);
    }
  }

  Future<void> initialise(String tablePrefix) async {
    if (!await isSchemaCreated(tablePrefix)) {
      await createSchema(tablePrefix);
    }
  }

  bool get hasReachedMax {
    final reachedMax = _total > -1 && _items.length >= _total;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchData(String tablePrefix) async {
    final page = _items.length ~/ defaultPageSize;
    _log.d('page $page');
    final documentList = await getDocumentList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('documentList.total ${documentList.total}');
    if (documentList.total > 0 && documentList.total > _items.length) {
      _items.addAll(
        documentList.items
            .map(
              (item) => DocumentItem(tablePrefix, item),
            )
            .toList(),
      );
      _total = documentList.total;
      notifyListeners();
    }
  }

  Future<void> addItem(String tablePrefix, Document? document) async {
    if (document != null) {
      final createdDocument = await createDocument(tablePrefix, document);
      if (createdDocument.id != null) {
        final documentItem = DocumentItem(
          tablePrefix,
          createdDocument,
          0,
          CancelToken(),
        );
        _items.insert(0, documentItem);
        notifyListeners();
        _log.d('0. documentItem.hashCode ${documentItem.hashCode}');
        await _split(documentItem);
      }
    }
  }

  Future<void> clearData(String tablePrefix) async {
    _total = -1;
    _items.clear();
    await _documentRepository.deleteAllDocuments(tablePrefix);
    await _embeddingRepository.deleteAllEmbeddings(tablePrefix);
    notifyListeners();
  }

  Future<Object?> updateDocumentAndCreateEmbeddings(
    String tablePrefix,
    Document document,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    final documentEmbeddings = <DocumentEmbedding>[];
    for (final embedding in embeddings) {
      documentEmbeddings.add(
        DocumentEmbedding(
          documentId: document.id!,
          embeddingId: embedding.id!,
        ),
      );
    }

    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _documentRepository.updateDocument(
            document,
            txn,
          );

          await _embeddingRepository.createEmbeddings(
            tablePrefix,
            embeddings,
            txn,
          );
          await _documentEmbeddingRepository.createDocumentEmbeddings(
            tablePrefix,
            documentEmbeddings,
            txn,
          );
        },
      );
    } else {
      await _documentRepository.updateDocument(document, txn);
      await _embeddingRepository.createEmbeddings(tablePrefix, embeddings, txn);
      await _documentEmbeddingRepository.createDocumentEmbeddings(
        tablePrefix,
        documentEmbeddings,
        txn,
      );
      return null;
    }
  }

  Future<Object?> updateEmbeddings(
    String tablePrefix,
    List<Embedding> embeddings,
    List<List<double>> vectors, [
    Transaction? txn,
  ]) async {
    assert(
      embeddings.length == vectors.length,
      'embeddings(${embeddings.length}) != vectors(${vectors.length})',
    );
    final now = DateTime.now();
    if (txn == null) {
      return _db.transaction(
        (txn) async {
          for (var i = 0; i < embeddings.length; i++) {
            await _embeddingRepository.updateEmbedding(
              embeddings[i].copyWith(
                embedding: vectors[i],
                updated: now,
              ),
              txn,
            );
          }
        },
      );
    } else {
      for (var i = 0; i < embeddings.length; i++) {
        await _embeddingRepository.updateEmbedding(
          embeddings[i].copyWith(
            embedding: vectors[i],
            updated: now,
          ),
          txn,
        );
      }
      return null;
    }
  }

  Future<Document> createDocument(String tablePrefix, Document document) async {
    final base64EncodedFile = await _compressFileToBase64(
      document.byteData!.first,
    );
    final newDocument = document.copyWith(
      compressedFileSize: base64EncodedFile.length,
      file: base64EncodedFile,
    );
    return _documentRepository.createDocument(
      tablePrefix,
      newDocument,
    );
  }

  Future<Document?> getDocumentById(String id) async {
    var document = await _documentRepository.getDocumentById(id);

    if (document != null && document.file != null) {
      document = document.copyWith(
        byteData: [await _decompressFileFromBase64(document.file!)],
      );
    }
    return document;
  }

  Future<String> convertByteDataToString(List<List<int>> byteData) async {
    final buffer = StringBuffer();
    await Stream.fromIterable(byteData)
        .transform(
          utf8.decoder,
        )
        .forEach(
          buffer.write,
        );
    return buffer.toString();
  }

  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
    double threshold,
  ) async {
    return _embeddingRepository.similaritySearch(
      tablePrefix,
      vector,
      k,
      threshold,
    );
  }

  Future<DocumentList> getDocumentList(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final items = await _documentRepository.getAllDocuments(
      tablePrefix,
      page: page,
      pageSize: pageSize,
      ascendingOrder: ascendingOrder,
    );
    final total = await _documentRepository.getTotal(tablePrefix);
    return DocumentList(items, total);
  }

  bool _isGzFile(List<int> fileBytes) {
    return fileBytes[0] == 0x1f && fileBytes[1] == 0x8b;
  }

  Future<String> _compressFileToBase64(List<int> bytes) async {
    if (_isGzFile(bytes)) {
      return base64Encode(bytes);
    } else {
      return base64Encode(
        _gzipEncoder.encode(bytes)!,
      );
    }
  }

  Future<List<int>> _decompressFileFromBase64(String file) async {
    final bytes = base64Decode(file);
    return _isGzFile(bytes) ? _gzipDecoder.decodeBytes(bytes) : bytes;
  }

  //--- Document Item ---//
  Future<void> _split(DocumentItem documentItem) async {
    if (documentItem.item.status == DocumentStatus.created) {
      await _updateDocumentStatus(documentItem, DocumentStatus.pending);
    }
    if (documentItem.item.status == DocumentStatus.pending) {
      _log.d(documentItem.item.id);
      documentItem.item = (await getDocumentById(documentItem.item.id!))!;
      final chunkSize = _settingService.get(chunkSizeKey, type: int).value;
      final chunkOverlap =
          _settingService.get(chunkOverlapKey, type: int).value;
      final url = StringBuffer()
        ..write(_settingService.get(splitApiUrlKey).value)
        ..write('?$chunkSizeQueryString=$chunkSize')
        ..write('&$chunkOverlapQueryString=$chunkOverlap');

      _log.d('url $url');

      await _apiService.split(
        _dio,
        url.toString(),
        documentItem,
        _updateDocumentStatus,
        _onProgress,
        _onSplitCompleted,
        _onError,
      );
    }
  }

  Future<void> _updateDocumentStatus(
    DocumentItem documentItem,
    DocumentStatus status,
  ) async {
    _log.d('item.name ${documentItem.item.name}, status $status');
    documentItem.item = (await _documentRepository.updateDocumentStatus(
      documentItem.item.copyWith(
        status: status,
      ),
    ))!;
    _log.d('done!');
    notifyListeners();
  }

  Future<void> _handleError(
    DocumentItem documentItem,
    String? errorMessage,
  ) async {
    _log.e(errorMessage);
    final now = DateTime.now();
    documentItem.item = (await _documentRepository.updateDocument(
      documentItem.item.copyWith(
        status: DocumentStatus.failed,
        errorMessage: errorMessage,
        done: now,
        updated: now,
      ),
    ))!;
    notifyListeners();
  }

  void _onProgress(
    DocumentItem documentItem,
    double progress,
  ) {
    documentItem.progress = progress;
    notifyListeners();
  }

  Future<void> _onSplitCompleted(
    DocumentItem documentItem,
    Map<String, dynamic>? responseData,
  ) async {
    _log.d('responseData $responseData');
    final embeddings = await _splitted(documentItem, responseData).timeout(
      Duration(seconds: max((responseData?['items'] as List).length, 5)),
    );
    await _indexing(documentItem, embeddings).timeout(
      Duration(seconds: max(embeddings.length, 5)),
    );
  }

  Future<List<Embedding>> _splitted(
    DocumentItem documentItem,
    Map<String, dynamic>? responseData,
  ) async {
    _log.d('1. documentItem.hashCode ${documentItem.hashCode}');
    final documentItems =
        List<Map<String, dynamic>>.from(responseData?['items'] as List);
    if (documentItems.isEmpty) {
      final document = await getDocumentById(documentItem.item.id!);
      documentItems.add({
        'content': await convertByteDataToString(
          document!.byteData!,
        ),
      });
    }

    final now = DateTime.now();
    final fullTableName = '${documentItem.tablePrefix}_${Embedding.tableName}';
    final emptyEmbedding = List<double>.filled(384, 0);
    final embeddings = List<Embedding>.from(
      documentItems
          .map(
            (item) => Embedding(
              id: '$fullTableName:${Ulid()}',
              content: item['content'] as String,
              embedding: emptyEmbedding,
              metadata: item['metadata'],
            ),
          )
          .toList(),
    );
    final document = documentItem.item.copyWith(
      content: responseData?['content'] != null
          ? responseData!['content'] as String
          : null,
      contentMimeType: responseData?['mime_type'] as String,
      status: DocumentStatus.indexing,
      splitted: now,
      updated: now,
    );
    final txnResults = await updateDocumentAndCreateEmbeddings(
      documentItem.tablePrefix,
      document,
      embeddings,
    );
    final results = txnResults! as List;
    assert(
      (results[1] as List).length == embeddings.length,
      'Length of the document embeddings result should equals to embeddings',
    );
    documentItem.item = document;
    _log.d('2. documentItem.hashCode ${documentItem.hashCode}');
    notifyListeners();
    return embeddings;
  }

  Future<void> _indexing(
    DocumentItem documentItem,
    List<Embedding> embeddings,
  ) async {
    final chunkedTexts = embeddings
        .map(
          (embedding) => embedding.content,
        )
        .toList();

    final vectors = await _apiService.index(
      _dio,
      _settingService.get(embeddingsModelKey).value,
      _settingService.get(embeddingsApiUrlKey).value,
      _settingService.get(embeddingsApiKey).value,
      chunkedTexts,
      batchSize: int.parse(
        _settingService.get(embeddingsApiBatchSizeKey, type: int).value,
      ),
      dimensions: int.parse(
        _settingService.get(embeddingsDimensionsKey, type: int).value,
      ),
    );
    //.timeout(
    //  Duration(seconds: max(embeddings.length, 5)),
    //);

    await updateEmbeddings(
      documentItem.tablePrefix,
      embeddings,
      vectors,
    );
    //.timeout(
    //  Duration(seconds: max(embeddings.length, 5)),
    //);

    await _updateDocumentStatus(
      documentItem, 
      DocumentStatus.completed,
    );
    //.timeout(
    //  Duration(seconds: max(embeddings.length,5)),
    //);
  }

  // ignore: prefer_void_to_null
  Future<Null> _onError(DocumentItem documentItem, dynamic error) async {
    _log.e(error);
    // Handle the error in here
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        final now = DateTime.now();
        documentItem.item = (await _documentRepository.updateDocument(
          documentItem.item.copyWith(
            status: DocumentStatus.canceled,
            done: now,
            updated: now,
          ),
        ))!;

        notifyListeners();
      } else {
        await _handleError(documentItem, error.message);
      }
    } else {
      await _handleError(documentItem, error.toString());
    }
  }
}
