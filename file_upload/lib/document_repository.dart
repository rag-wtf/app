import 'dart:convert';

import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'document.dart';

class DocumentRepository {
  final Surreal db;

  const DocumentRepository({
    required this.db,
  });

  Future<Document> createDocument(Document document) async {
    document = document.validate();
    final isValid = document.errors == null;
    if (!isValid) {
      return document;
    }
    final payload = document.toJson();
    print(jsonEncode(payload));
    final result = await db.query(
      'CREATE ONLY Document CONTENT ${jsonEncode(payload)}',
    );

    return Document.fromJson(
      Map<String, dynamic>.from(
        (result as List).first as Map,
      ),
    );
  }

  Future<List<Document>> getAllDocuments() async {
    final results = await db.query("SELECT * FROM Document") as List;
    return results
        .map(
          (result) => Document.fromJson(
            Map<String, dynamic>.from(result as Map),
          ),
        )
        .toList();
  }

  Future<Document?> getDocumentById(String id) async {
    final result = await db.select(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(result as Map),
          )
        : null;
  }

  Future<Document?> updateDocument(Document document) async {
    document = document.validate();
    final isValid = document.errors == null;
    if (!isValid) {
      return document;
    }

    final payload = document.toJson();
    final id = payload.remove('id');
    if (await db.select(id) == null) return null;

    payload.removeWhere((key, value) => value == null);
    final result = await db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Document.fromJson(
      Map<String, dynamic>.from(
        (result as List).first as Map,
      ),
    );
  }

  Future<Document?> deleteDocument(String id) async {
    final result = await db.delete(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(result as Map),
          )
        : null;
  }
}
