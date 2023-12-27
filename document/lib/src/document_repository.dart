import 'dart:convert';

import 'package:document/src/document.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentRepository {
  const DocumentRepository({
    required this.db,
  });
  final Surreal db;

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Document.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Document.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await db.query(sqlSchema) : txn.query(sqlSchema);
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
      final result = await db.query(sql);

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

  Future<List<Document>> getAllDocuments(String tablePrefix) async {
    final results = (await db
        .query('SELECT * FROM ${tablePrefix}_${Document.tableName}'))! as List;
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

  Future<Document?> getDocumentById(String id) async {
    final result = await db.select(id);

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
    if (await db.select(id) == null) return null;

    final result = await db.query(
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
    final result = await db.delete(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(
              Document.toMap(result) as Map,
            ),
          )
        : null;
  }
}
