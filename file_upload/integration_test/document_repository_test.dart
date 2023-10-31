import 'dart:convert';
import 'dart:typed_data';

import 'package:file_upload/document.dart';
import 'package:file_upload/document_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DocumentRepository repository;
  final db = Surreal();
  const documentSql = '''
DEFINE TABLE Document SCHEMALESS;
DEFINE FIELD compressedFileSize ON Document TYPE number;
DEFINE FIELD content ON Document TYPE option<string>;
DEFINE FIELD contentType ON Document TYPE string;
DEFINE FIELD created ON Document TYPE datetime;
DEFINE FIELD errorMessage ON Document TYPE string;
DEFINE FIELD file ON Document TYPE option<string>;
DEFINE FIELD name ON Document TYPE string;
DEFINE FIELD originFileSize ON Document TYPE number;
DEFINE FIELD status ON Document TYPE string;
DEFINE FIELD updated ON Document TYPE option<datetime>;
''';

  setUpAll(() async {
    await db.connect('mem://');
    await db.use(ns: 'test', db: 'test');
    await db.query(documentSql);
    repository = DocumentRepository(db: db);
  });

  group('createDocument', () {
    test('should create document', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        contentType: 'text/plain',
        created: DateTime.now(),
        errorMessage: '',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );

      // Act
      final result = await repository.createDocument(document);

      // Assert
      expect(result.id, isNotNull);
    });

    test('should have validation errors', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        contentType: '',
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );

      // Act
      final result = await repository.createDocument(document);

      // Assert
      expect(result.errors?.first.toString(),
          '/contentType: minLength violated ( vs 1)');
    });
  });

  group('getAllDocuments', () {
    test('should return a list of documents', () async {
      // Arrange
      final documents = [
        {
          'compressedFileSize': 100,
          'contentType': 'text/plain',
          'created': '2023-10-31T03:19:16.601Z',
          'errorMessage': '',
          'name': 'Test Document 1',
          'originFileSize': 200,
          'status': 'active',
          'updated': '2023-10-31T03:19:16.601Z',
        },
        {
          'compressedFileSize': 150,
          'contentType': 'text/html',
          'created': '2022-01-01T13:00:00Z',
          'errorMessage': '',
          'file': 'base64 encoded string',
          'name': 'Test Document 2',
          'originFileSize': 250,
          'status': 'inactive',
          'updated': '2022-01-01T13:00:00Z',
        },
      ];
      await db.delete('Document');
      await db.query('INSERT INTO Document ${jsonEncode(documents)}');

      // Act
      final result = await repository.getAllDocuments();

      // Assert
      expect(result, hasLength(documents.length));
    });
  });

  group('getDocumentById', () {
    test('should return a document by id', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        contentType: 'text/plain',
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );
      final result = await repository.createDocument(document);
      String id = result.id!;

      // Act
      final getDocumentById = await repository.getDocumentById(id);

      // Assert
      expect(getDocumentById?.id, equals(id));
      expect(
        getDocumentById?.file,
        equals(
          'base64 encoded string',
        ),
      );
    });

    test('should not found', () async {
      // Arrange
      const id = 'Document:1';

      // Act & Assert
      expect(await repository.getDocumentById(id), isNull);
    });
  });

  group('updateDocument', () {
    test('should update document', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        contentType: 'text/plain',
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );
      final created = await repository.createDocument(document);

      // Act
      final updated =
          await repository.updateDocument(created.copyWith(status: 'inactive'));

      // Assert
      expect(updated?.status, equals('inactive'));
    });

    test('should be null when the update document is not found', () async {
      // Arrange
      final document = Document(
        id: 'Document:1',
        compressedFileSize: 100,
        contentType: 'text/plain',
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );

      // Act & Assert
      expect(await repository.updateDocument(document), isNull);
    });
  });

  group('deleteDocument', () {
    test('should delete document', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        contentType: 'text/plain',
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );
      final created = await repository.createDocument(document);

      // Act
      final result = await repository.deleteDocument(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete document is not found', () async {
      // Arrange
      const id = 'Document:1';

      // Act & Assert
      expect(await repository.deleteDocument(id), isNull);
    });
  });
}
