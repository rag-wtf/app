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
    final payload = documentEmbedding.toJson();
    final validationErrors = DocumentEmbedding.validate(payload);
    print(validationErrors);
    final isValid = validationErrors == null;
    if (!isValid) {
      return documentEmbedding.copyWith(errors: validationErrors);
    }

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

  Future<List<DocumentEmbedding>> createEmbeddings(
    List<DocumentEmbedding> documentEmbeddings, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (var i = 0; i < documentEmbeddings.length; i++) {
      final documentEmbedding = documentEmbeddings[i];
      final payload = documentEmbedding.toJson();
      final validationErrors = DocumentEmbedding.validate(payload);
      final isValid = validationErrors == null;
      if (isValid) {
        final documentId = documentEmbedding.documentId;
        final embeddingId = documentEmbedding.embeddingId;
        sqlBuffer.write(
          'RELATE ONLY $documentId->DocumentEmbedding->$embeddingId;',
        );
      } else {
        documentEmbeddings[i] =
            documentEmbedding.copyWith(errors: validationErrors);
        return documentEmbeddings;
      }
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
    const sql = r'''
SELECT ->DocumentEmbedding->Embedding.* FROM Document 
WHERE array::first(array::distinct(->DocumentEmbedding<-Document)) == $documentId;
''';
    final bindings = {
      'documentId': documentId,
    };
    final results = (await db.query(
      sql,
      bindings: bindings,
    ))! as List;
    return results
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
