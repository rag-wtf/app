import 'dart:convert';

import 'package:document/src/embedding.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class EmbeddingRepository {
  const EmbeddingRepository({
    required this.db,
  });
  final Surreal db;

  Future<void> createSchema([
    Transaction? txn,
  ]) async {
    txn == null
        ? await db.query(Embedding.sqlSchema)
        : txn.query(Embedding.sqlSchema);
  }

  Future<Embedding> createEmbedding(
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    final payload = embedding.toJson();
    final validationErrors = Embedding.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return embedding.copyWith(errors: validationErrors);
    }

    final sql = 'CREATE ONLY Embedding CONTENT ${jsonEncode(payload)}';
    if (txn == null) {
      final result = await db.query(sql);

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

    const sql = r'INSERT INTO Embedding $payloads';
    final bindings = {'payloads': payloads};

    if (txn == null) {
      final results = (await db.query(sql, bindings: bindings))! as List;

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

  Future<List<Embedding>> getAllEmbeddings() async {
    final results = (await db.query('SELECT * FROM Embedding'))! as List;
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
    final result = await db.select(id);

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
    if (await db.select(id) == null) return null;
    final result = await db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Embedding.fromJson(
      Map<String, dynamic>.from(
        (result! as List).first as Map,
      ),
    );
  }

  Future<Embedding?> deleteEmbedding(String id) async {
    final result = await db.delete(id);

    return result != null
        ? Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<List<Embedding>> similaritySearch(List<double> vector, int k) async {
    const sql = r'''
SELECT *, vector::similarity::cosine(embedding, $vector) AS score
FROM Embedding
ORDER BY score DESC
LIMIT $k;''';

    final bindings = {
      'vector': vector,
      'k': k,
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
