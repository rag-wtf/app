import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_embedding.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentService {
  final _db = locator<Surreal>();
  final _documentRepository = locator<DocumentRepository>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();
  final _gzipEncoder = locator<GZipEncoder>();
  final _gzipDecoder = locator<GZipDecoder>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
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

  Future<Object?> createDocumentEmbeddings(
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
          await _documentRepository.createDocument(tablePrefix, document, txn);
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
      await _documentRepository.createDocument(tablePrefix, document, txn);
      await _embeddingRepository.createEmbeddings(tablePrefix, embeddings, txn);
      await _documentEmbeddingRepository.createDocumentEmbeddings(
        tablePrefix,
        documentEmbeddings,
        txn,
      );
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
  ) async {
    return _embeddingRepository.similaritySearch(tablePrefix, vector, k);
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
}
