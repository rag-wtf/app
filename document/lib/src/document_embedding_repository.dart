import 'package:document/src/document.dart';
import 'package:document/src/document_embedding.dart';
import 'package:document/src/embedding.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentEmbeddingRepository {
  const DocumentEmbeddingRepository({
    required this.db,
  });
  final Surreal db;

  Future<void> createSchema([
    Transaction? txn,
  ]) async {
    txn == null
        ? await db.query(DocumentEmbedding.sqlSchema)
        : txn.query(DocumentEmbedding.sqlSchema);
  }

  Future<DocumentEmbedding> createDocumentEmbedding(
    DocumentEmbedding documentEmbedding, [
    Transaction? txn,
  ]) async {
    final documentId = documentEmbedding.documentId;
    final embeddingId = documentEmbedding.embeddingId;

    final sql = 'RELATE ONLY $documentId->DocumentEmbedding->$embeddingId;';
    if (txn == null) {
      final result = await db.query(
        sql,
      );

      final map = (result! as List).first as Map;
      map['documentId'] = map.remove('in');
      map['embeddingId'] = map.remove('out');
      return DocumentEmbedding.fromJson(
        Map<String, dynamic>.from(map),
      );
    } else {
      txn.query(
        sql,
      );
      return documentEmbedding;
    }
  }

  Future<List<DocumentEmbedding>> createDocumentEmbeddings(
    List<DocumentEmbedding> documentEmbeddings, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final documentEmbedding in documentEmbeddings) {
      final documentId = documentEmbedding.documentId;
      final embeddingId = documentEmbedding.embeddingId;
      sqlBuffer.write(
        'RELATE ONLY $documentId->DocumentEmbedding->$embeddingId;',
      );
    }

    if (txn == null) {
      final results = (await db.query(sqlBuffer.toString()))! as List;

      return results.map(
        (result) {
          final map = result as Map;
          map['documentId'] = map.remove('in');
          map['embeddingId'] = map.remove('out');
          return DocumentEmbedding.fromJson(
            Map<String, dynamic>.from(map),
          );
        },
      ).toList();
    } else {
      txn.query(sqlBuffer.toString());
      return documentEmbeddings;
    }
  }

  Future<List<Embedding>> getAllEmbeddingsOfDocument(String documentId) async {
    final sql = '''
SELECT ->DocumentEmbedding->Embedding.* AS Embedding FROM Document 
WHERE array::first(array::distinct(->DocumentEmbedding<-Document)) == $documentId;
''';

    final results = (await db.query(
      sql,
    ))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final embeddings = result['Embedding'] as List;

    return embeddings
        .map(
          (result) => Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }
}
