import 'dart:convert';

import 'package:document/src/document.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DocumentRepository {
  const DocumentRepository({
    required this.db,
  });
  final Surreal db;

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
