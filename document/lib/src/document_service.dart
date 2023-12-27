import 'package:document/src/document.dart';
import 'package:document/src/document_embedding.dart';
import 'package:document/src/document_embedding_repository.dart';
import 'package:document/src/document_repository.dart';
import 'package:document/src/embedding.dart';
import 'package:document/src/embedding_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentService {
  //final _log = getLogger('DocumentService');

  DocumentService({
    required this.db,
  }) {
    documentRepository = DocumentRepository(db: db);
    embeddingRepository = EmbeddingRepository(db: db);
    documentEmbeddingRepository = DocumentEmbeddingRepository(db: db);
  }

  final Surreal db;
  late DocumentRepository documentRepository;
  late EmbeddingRepository embeddingRepository;
  late DocumentEmbeddingRepository documentEmbeddingRepository;

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await db.query('INFO FOR DB'))! as List;
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
      await db.transaction(
        (txn) async {
          await documentRepository.createSchema(tablePrefix, txn);
          await embeddingRepository.createSchema(tablePrefix, txn);
          await documentEmbeddingRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await documentRepository.createSchema(tablePrefix, txn);
      await embeddingRepository.createSchema(tablePrefix, txn);
      await documentEmbeddingRepository.createSchema(tablePrefix, txn);
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
      return db.transaction(
        (txn) async {
          await documentRepository.createDocument(tablePrefix, document, txn);
          await embeddingRepository.createEmbeddings(
            tablePrefix,
            embeddings,
            txn,
          );
          await documentEmbeddingRepository.createDocumentEmbeddings(
            tablePrefix,
            documentEmbeddings,
            txn,
          );
        },
      );
    } else {
      await documentRepository.createDocument(tablePrefix, document, txn);
      await embeddingRepository.createEmbeddings(tablePrefix, embeddings, txn);
      await documentEmbeddingRepository.createDocumentEmbeddings(
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
    return embeddingRepository.similaritySearch(tablePrefix, vector, k);
  }
}
