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
    final total = await getTotal(tablePrefix);
    if (total > 0) {
      return '''
Cannot change dimensions, there are existing embeddings in the database.''';
    } else {
      final sql = Embedding.defineEmbeddingsMtreeIndex
          .replaceAll('{prefix}', tablePrefix)
          .replaceFirst('{dimensions}', dimensions);
      await _db.query(sql);
      return null;
    }
  }

  Future<Object?> rebuildEmbeddingIndex(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    _log.d('rebuildEmbeddingIndex($tablePrefix)');
    final sql = Embedding.rebuildEmbeddingsMtreeIndex
        .replaceAll('{prefix}', tablePrefix);
    if (txn == null) {
      return _db.query(sql);
    } else {
      txn.query(sql);
      return null;
    }
  }

  Future<Embedding> createEmbedding(
    String tablePrefix,
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    final payload = embedding.toJson();
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
    final payloads = embeddings.map((embedding) => embedding.toJson()).toList();
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
    String tablePrefix,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      final results = await _db.transaction(
        showSql: true,
        timeout: Duration(seconds: embeddings.length),
        (txn) async {
          for (final embedding in embeddings) {
            await updateEmbedding(
              tablePrefix,
              embedding,
              txn,
            );
          }
          await rebuildEmbeddingIndex(tablePrefix, txn);
        },
      );

      return results is Iterable ? results as List : [results];
    } else {
      for (final embedding in embeddings) {
        await updateEmbedding(
          tablePrefix,
          embedding,
          txn,
        );
      }
      await rebuildEmbeddingIndex(tablePrefix, txn);
      return List.empty();
    }
  }

  Future<Embedding?> updateEmbedding(
    String tablePrefix,
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    final fullEmbeddingTableName = '${tablePrefix}_${Embedding.tableName}';
    final embeddingId = embedding.id!.startsWith(fullEmbeddingTableName)
        ? embedding.id!
        : '$fullEmbeddingTableName:${embedding.id!}';
    if (!((await _db.query('RETURN record::exists(r"$embeddingId")'))!
        as bool)) {
      return null;
    }

    final payload = embedding.toJson();
    payload.remove('id') as String;
    final sql = 'UPDATE ONLY $embeddingId MERGE ${jsonEncode(payload)};';
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
  WHERE embedding <|$k|> $vector
)
WHERE score >= $threshold
ORDER BY score DESC;
''';
    _log.d('sql $sql');
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
