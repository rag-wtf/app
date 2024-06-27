import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_embedding.dart';
import 'package:document/src/services/embedding.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class DocumentEmbeddingRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${DocumentEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema =
        DocumentEmbedding.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<DocumentEmbedding> createDocumentEmbedding(
    String tablePrefix,
    DocumentEmbedding documentEmbedding, [
    Transaction? txn,
  ]) async {
    final documentId = documentEmbedding.documentId;
    final embeddingId = documentEmbedding.embeddingId;

    final sql = '''
RELATE ONLY $documentId->${tablePrefix}_${DocumentEmbedding.tableName}->$embeddingId;''';
    if (txn == null) {
      final result = await _db.query(
        sql,
      );

      final map = result! as Map;
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
    String tablePrefix,
    List<DocumentEmbedding> documentEmbeddings, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final documentEmbedding in documentEmbeddings) {
      final documentId = documentEmbedding.documentId;
      final embeddingId = documentEmbedding.embeddingId;
      final fullTableName = '${tablePrefix}_${DocumentEmbedding.tableName}';
      sqlBuffer.write('RELATE ONLY $documentId->$fullTableName->$embeddingId;');
    }

    if (txn == null) {
      final results = (await _db.query(sqlBuffer.toString()))! as List;

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

  Future<List<Embedding>> getAllEmbeddingsOfDocument(
    String tablePrefix,
    String documentId,
  ) async {
    final documentEmbeddingTableName =
        '${tablePrefix}_${DocumentEmbedding.tableName}';
    final documentTableName = '${tablePrefix}_${Document.tableName}';
    final sql = '''
SELECT ->$documentEmbeddingTableName->${tablePrefix}_${Embedding.tableName}.* 
AS Embedding FROM $documentTableName 
WHERE array::first(array::distinct(->$documentEmbeddingTableName<-$documentTableName)) == $documentId;
''';

    final results = (await _db.query(
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
