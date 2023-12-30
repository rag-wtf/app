import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<DocumentRepository>();

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isFalse);
    });

    test('should create schema and return true', () async {
      // Arrange
      if (!await repository.isSchemaCreated(defaultTablePrefix)) {
        await repository.createSchema(defaultTablePrefix);
      }
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isTrue);
    });
  });

  group('createDocument', () {
    test('should create document', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
        updated: DateTime.now(),
      );

      // Act
      final result =
          await repository.createDocument(defaultTablePrefix, document);

      // Assert
      expect(result.id, isNotNull);
    });

    test('should have validation errors', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: '',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
        updated: DateTime.now(),
      );

      // Act
      final result =
          await repository.createDocument(defaultTablePrefix, document);

      // Assert
      expect(
        result.errors?.first.toString(),
        '/contentMimeType: minLength violated ( vs 1)',
      );
    });
  });

  group('getAllDocuments', () {
    test('should return a list of documents', () async {
      // Arrange
      final documents = [
        {
          'compressedFileSize': 100,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'tokensCount': 10,
          'created': '2023-10-31T03:19:16.601Z',
          'errorMessage': '',
          'name': 'Test Document 1',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
          'updated': '2023-10-31T03:19:16.601Z',
        },
        {
          'compressedFileSize': 150,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'tokensCount': 10,
          'created': '2022-01-01T13:00:00Z',
          'errorMessage': '',
          'file': 'base64 encoded string',
          'name': 'Test Document 2',
          'originFileSize': 250,
          'status': DocumentStatus.created.name,
          'updated': '2022-01-01T13:00:00Z',
        },
      ];
      await db.delete('${defaultTablePrefix}_${Document.tableName}');
      final sql = '''
INSERT INTO ${defaultTablePrefix}_${Document.tableName} ${jsonEncode(documents)}''';
      await db.query(sql);

      // Act
      final result = await repository.getAllDocuments(defaultTablePrefix);

      // Assert
      expect(result, hasLength(documents.length));
    });

    test('should return documents by page', () async {
      // Arrange
      final documents = List.generate(
        5,
        (index) => {
          'compressedFileSize': 100,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'tokensCount': 10,
          'created': '2023-10-31T03:1$index:16.601Z',
          'name': 'doc$index',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
          'updated': '2023-10-31T03:1$index:16.601Z',
        },
      );
      await db.delete('${defaultTablePrefix}_${Document.tableName}');
      final sql = '''
INSERT INTO ${defaultTablePrefix}_${Document.tableName} ${jsonEncode(documents)}''';
      await db.query(sql);

      // Act
      const pageSize = 2;
      final page1 = await repository.getAllDocuments(
        defaultTablePrefix,
        page: 0,
        pageSize: pageSize,
        ascendingOrder: true,
      );
      final page2 = await repository.getAllDocuments(
        defaultTablePrefix,
        page: 1,
        pageSize: pageSize,
        ascendingOrder: true,
      );
      final page3 = await repository.getAllDocuments(
        defaultTablePrefix,
        page: 2,
        pageSize: pageSize,
        ascendingOrder: true,
      );

      // Assert
      expect(page1, hasLength(pageSize));
      expect(page1[0].name, equals('doc0'));
      expect(page1[1].name, equals('doc1'));
      expect(page2, hasLength(pageSize));
      expect(page2[0].name, equals('doc2'));
      expect(page2[1].name, equals('doc3'));
      expect(page3, hasLength(1));
      expect(page3[0].name, equals('doc4'));
    });
  });

  group('getTotal', () {
    test('should return 2', () async {
      // Arrange
      final documents = [
        {
          'compressedFileSize': 100,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'tokensCount': 10,
          'created': '2023-10-31T03:19:16.601Z',
          'errorMessage': '',
          'name': 'Test Document 1',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
          'updated': '2023-10-31T03:19:16.601Z',
        },
        {
          'compressedFileSize': 150,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'tokensCount': 10,
          'created': '2022-01-01T13:00:00Z',
          'errorMessage': '',
          'file': 'base64 encoded string',
          'name': 'Test Document 2',
          'originFileSize': 250,
          'status': DocumentStatus.created.name,
          'updated': '2022-01-01T13:00:00Z',
        },
      ];
      await db.delete('${defaultTablePrefix}_${Document.tableName}');
      final sql = '''
INSERT INTO ${defaultTablePrefix}_${Document.tableName} ${jsonEncode(documents)}''';
      await db.query(sql);

      // Act
      final result = await repository.getTotal(defaultTablePrefix);

      // Assert
      expect(result, equals(documents.length));
    });
  });

  group('getDocumentById', () {
    test('should return a document by id', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
        updated: DateTime.now(),
      );
      final result =
          await repository.createDocument(defaultTablePrefix, document);
      final id = result.id!;

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
      const id = '${defaultTablePrefix}_${Document.tableName}:1';

      // Act & Assert
      expect(await repository.getDocumentById(id), isNull);
    });
  });

  group('updateDocument', () {
    test('should update document', () async {
      // Arrange
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
        updated: DateTime.now(),
      );
      final created =
          await repository.createDocument(defaultTablePrefix, document);

      // Act
      final updated = await repository.updateDocument(
        created.copyWith(status: DocumentStatus.pending),
      );

      // Assert
      expect(updated?.status, equals(DocumentStatus.pending));
    });

    test('should be null when the update document is not found', () async {
      // Arrange
      final document = Document(
        id: '${defaultTablePrefix}_${Document.tableName}:1',
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
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
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
        updated: DateTime.now(),
      );
      final created =
          await repository.createDocument(defaultTablePrefix, document);

      // Act
      final result = await repository.deleteDocument(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete document is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Document.tableName}:1';

      // Act & Assert
      expect(await repository.deleteDocument(id), isNull);
    });
  });
}
