import 'package:document/src/document.dart';
import 'package:document/src/document_embedding.dart';
import 'package:document/src/document_embedding_repository.dart';
import 'package:document/src/document_repository.dart';
import 'package:document/src/embedding.dart';
import 'package:document/src/embedding_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentService {
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

  Future<bool> isSchemaCreated() async {
    final results = (await db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('Document') &&
        tables.containsKey('Embedding') &&
        tables.containsKey('DocumentEmbedding');
  }

  Future<void> createSchema([
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await db.transaction(
        (txn) async {
          await documentRepository.createSchema(txn);
          await embeddingRepository.createSchema(txn);
          await documentEmbeddingRepository.createSchema(txn);
        },
      );
    } else {
      await documentRepository.createSchema(txn);
      await embeddingRepository.createSchema(txn);
      await documentEmbeddingRepository.createSchema(txn);
    }
  }

  Future<Object?> createDocumentEmbeddings(
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
          await documentRepository.createDocument(document, txn);
          await embeddingRepository.createEmbeddings(embeddings, txn);
          await documentEmbeddingRepository.createDocumentEmbeddings(
            documentEmbeddings,
            txn,
          );
        },
      );
    } else {
      await documentRepository.createDocument(document, txn);
      await embeddingRepository.createEmbeddings(embeddings, txn);
      await documentEmbeddingRepository.createDocumentEmbeddings(
        documentEmbeddings,
        txn,
      );
      return null;
    }
  }
}
