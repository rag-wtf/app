import 'dart:convert';

import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/embedding.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class EmbeddingRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('EmbeddingRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Embedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix,
    String dimensions, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Embedding.sqlSchema
        .replaceAll('{prefix}', tablePrefix)
        .replaceFirst('{dimensions}', dimensions);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<String?> redefineEmbeddingIndex(
    String tablePrefix,
    String dimensions,
  ) async {
    _log.d('redefineEmbeddingIndex($tablePrefix, $dimensions)');
    final sql = Embedding.redefineEmbeddingsMtreeIndex
        .replaceAll('{prefix}', tablePrefix)
        .replaceFirst('{dimensions}', dimensions);
    final total = await getTotal(tablePrefix);
    if (total > 0) {
      return '''
Cannot change dimensions,
There are existing embeddings in the database.''';
    } else {
      await _db.query(sql);
      return null;
    }
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
          result! as Map,
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

  Future<List<dynamic>> updateEmbeddings(
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      final results = (await _db.transaction(
        (txn) async {
          for (final embedding in embeddings) {
            await updateEmbedding(
              embedding,
              txn,
            );
          }
        },
      ))!;

      return results is Iterable ? results as List : [results];
    } else {
      for (final embedding in embeddings) {
        await updateEmbedding(
          embedding,
          txn,
        );
      }
      return List.empty();
    }
  }

  Future<Embedding?> updateEmbedding(
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    if (await _db.select(embedding.id!) == null) return null;

    final payload = embedding.toJson();
    final validationErrors = Embedding.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return embedding.copyWith(errors: validationErrors);
    }
    final id = payload.remove('id') as String;
    final sql = 'UPDATE ONLY $id MERGE ${jsonEncode(payload)};';
    if (txn == null) {
      final result = await _db.query(sql);
      return Embedding.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return null;
    }
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

  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
    double threshold,
  ) async {
    final sql = '''
SELECT * FROM (
  SELECT *, vector::similarity::cosine(embedding, $vector) AS score
  FROM ${tablePrefix}_${Embedding.tableName}
  WHERE embedding <$k> $vector
)
WHERE score >= $threshold
ORDER BY score DESC;
''';

    final results = (await _db.query(
      sql,
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

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Embedding.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return results.isEmpty ? 0 : (results.first as Map)['count'] as int;
  }

  Future<void> deleteAllEmbeddings(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Embedding.tableName}');
  }
}
