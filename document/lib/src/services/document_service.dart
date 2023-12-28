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

  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
  ) async {
    return _embeddingRepository.similaritySearch(tablePrefix, vector, k);
  }
}
