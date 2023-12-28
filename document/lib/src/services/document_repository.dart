import 'dart:convert';

import 'package:document/src/app/app.locator.dart';
import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Document.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Document.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Document> createDocument(
    String tablePrefix,
    Document document, [
    Transaction? txn,
  ]) async {
    final payload = document.toJson();
    final validationErrors = Document.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return document.copyWith(errors: validationErrors);
    }
    final fullTableName = '${tablePrefix}_${Document.tableName}';
    final sql = 'CREATE ONLY $fullTableName CONTENT ${jsonEncode(payload)};';
    if (txn == null) {
      final result = await _db.query(sql);

      return Document.fromJson(
        Map<String, dynamic>.from(
          Document.toMap(
            (result! as List).first,
          ) as Map,
        ),
      );
    } else {
      txn.query(sql);
      return document;
    }
  }

  Future<List<Document>> getAllDocuments(
    String tablePrefix, {
    int? page,
    int pageSize = defaultPageSize,
    bool ascendingOrder = defaultAscendingOrder,
  }) async {
    final sql = '''
SELECT * FROM ${tablePrefix}_${Document.tableName} 
ORDER BY updated ${ascendingOrder ? 'ASC' : 'DESC'}
${page == null ? ';' : ' LIMIT $pageSize START ${(page - 1) * pageSize};'}''';
    final results = (await _db.query(sql))! as List;
    return results
        .map(
          (result) => Document.fromJson(
            Map<String, dynamic>.from(
              Document.toMap(result) as Map,
            ),
          ),
        )
        .toList();
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Document.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return (results.first as Map)['count'] as int;
  }

  Future<Document?> getDocumentById(String id) async {
    final result = await _db.select(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(
              Document.toMap(result) as Map,
            ),
          )
        : null;
  }

  Future<Document?> updateDocument(Document document) async {
    final payload = document.toJson();
    final validationErrors = Document.validate(payload);
    final isValid = validationErrors == null;
    if (!isValid) {
      return document.copyWith(errors: validationErrors);
    }
    final id = payload.remove('id') as String;
    if (await _db.select(id) == null) return null;

    final result = await _db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Document.fromJson(
      Map<String, dynamic>.from(
        Document.toMap(
          (result! as List).first,
        ) as Map,
      ),
    );
  }

  Future<Document?> deleteDocument(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(
              Document.toMap(result) as Map,
            ),
          )
        : null;
  }
}
