import 'dart:convert';

import 'package:document/src/document.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentRepository {
  const DocumentRepository({
    required this.db,
  });
  final Surreal db;

  static const schemaSql = '''
DEFINE TABLE Document SCHEMALESS;
DEFINE FIELD compressedFileSize ON Document TYPE number;
DEFINE FIELD content ON Document TYPE option<string>;
DEFINE FIELD tokensCount ON Document TYPE number;
DEFINE FIELD fileMimeType ON Document TYPE string;
DEFINE FIELD contentMimeType ON Document TYPE string;
DEFINE FIELD created ON Document TYPE datetime;
DEFINE FIELD errorMessage ON Document TYPE option<string>;
DEFINE FIELD file ON Document TYPE option<string>;
DEFINE FIELD name ON Document TYPE string;
DEFINE FIELD originFileSize ON Document TYPE number;
DEFINE FIELD status ON Document TYPE string;
DEFINE FIELD updated ON Document TYPE option<datetime>;
DEFINE FIELD items ON Document TYPE option<array<object>>;
DEFINE FIELD items.*.content ON Document TYPE string;
DEFINE FIELD items.*.embedding ON Document TYPE array<float, 384>;
DEFINE FIELD items.*.metadata ON Document TYPE object;
DEFINE FIELD items.*.tokensCount ON Document TYPE number;
DEFINE FIELD items.*.updated ON Document TYPE option<datetime>;
''';

  Future<void> createSchema() async {
    await db.query(schemaSql);
  }

  Future<Document> createDocument(Document document) async {
    final validatedDocument = document.validate();
    final isValid = validatedDocument.errors == null;
    if (!isValid) {
      return validatedDocument;
    }
    final payload = document.toJson();
    final result = await db.query(
      'CREATE ONLY Document CONTENT ${jsonEncode(payload)}',
    );

    return Document.fromJson(
      Map<String, dynamic>.from(
        Document.toMap(
          (result! as List).first,
        ) as Map,
      ),
    );
  }

  Future<List<Document>> getAllDocuments() async {
    final results = (await db.query('SELECT * FROM Document'))! as List;
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
    final validatedDocument = document.validate();
    final isValid = validatedDocument.errors == null;
    if (!isValid) {
      return validatedDocument;
    }

    final payload = document.toJson();
    final id = payload.remove('id') as String;
    if (await db.select(id) == null) return null;

    payload.removeWhere((key, value) => value == null);
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
