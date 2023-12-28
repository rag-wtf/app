import 'dart:convert';

import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/embedding.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class EmbeddingRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Embedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Embedding.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Embedding> createEmbedding(
    String tablePrefix,
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    final payload = embedding.toJson();
    final validationErrors = Embedding.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return embedding.copyWith(errors: validationErrors);
    }

    final sql = '''
CREATE ONLY ${tablePrefix}_${Embedding.tableName} 
CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await _db.query(sql);

      return Embedding.fromJson(
        Map<String, dynamic>.from(
          (result! as List).first as Map,
        ),
      );
    } else {
      txn.query(sql);
      return embedding;
    }
  }

  Future<List<Embedding>> createEmbeddings(
    String tablePrefix,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    final payloads = <Map<String, dynamic>>[];
    for (var i = 0; i < embeddings.length; i++) {
      final embedding = embeddings[i];
      final payload = embedding.toJson();
      final validationErrors = Embedding.validate(payload);
      final isValid = validationErrors == null;
      if (isValid) {
        payloads.add(payload);
      } else {
        embeddings[i] = embedding.copyWith(errors: validationErrors);
        return embeddings;
      }
    }

    final sql = 'INSERT INTO ${tablePrefix}_${Embedding.tableName} \$payloads;';
    final bindings = {'payloads': payloads};

    if (txn == null) {
      final results = (await _db.query(sql, bindings: bindings))! as List;

      return results
          .map(
            (result) => Embedding.fromJson(
              Map<String, dynamic>.from(
                result as Map,
              ),
            ),
          )
          .toList();
    } else {
      txn.query(sql, bindings: bindings);
      return embeddings;
    }
  }

  Future<List<Embedding>> getAllEmbeddings(String tablePrefix) async {
    final results = (await _db
        .query('SELECT * FROM ${tablePrefix}_${Embedding.tableName}'))! as List;
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

  Future<Embedding?> getEmbeddingById(String id) async {
    final result = await _db.select(id);

    return result != null
        ? Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Embedding?> updateEmbedding(Embedding embedding) async {
    final payload = embedding.toJson();
    final validationErrors = Embedding.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return embedding.copyWith(errors: validationErrors);
    }
    final id = payload.remove('id') as String;
    if (await _db.select(id) == null) return null;
    final result = await _db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Embedding.fromJson(
      Map<String, dynamic>.from(
        (result! as List).first as Map,
      ),
    );
  }

  Future<Embedding?> deleteEmbedding(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  /* TODO: Re-test the following query in v1.1:
      const sql = r'''
SELECT *, vector::similarity::cosine(embedding, $vector) AS score
FROM Embedding
WHERE embedding <$k> $vector
ORDER BY score DESC;''';
*/
  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
  ) async {
    final sql = '''
SELECT *, vector::similarity::cosine(embedding, \$vector) AS score
FROM ${tablePrefix}_${Embedding.tableName}
ORDER BY score DESC
LIMIT \$k;''';

    final bindings = {
      'vector': vector,
      'k': k,
    };
    final results = (await _db.query(
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
