import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<DocumentRepository>();

  setUpAll(() async {
    if (wasm) {
      await db.connect(surrealIndxdbEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
    } else {
      await db.connect(surrealHttpEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
      await db
          .signin({'username': surrealUsername, 'password': surrealPassword});
    }
  });

  tearDownAll(() async {
    await db.close();
  });

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
      const fileContent = 'Hello world!';
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        name: 'Test Document',
        originFileSize: 200,
        file: utf8.encode(fileContent),
        status: DocumentStatus.created,
      );

      // Act
      final result =
          await repository.createDocument(defaultTablePrefix, document);

      // Assert
      expect(result.id, isNotNull);
    });
  });

  group('getAllDocuments', () {
    test('should return a list of documents', () async {
      // Arrange
      const fileContent = 'Hello world!';
      final documents = [
        {
          'compressedFileSize': 100,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'errorMessage': '',
          'name': 'Test Document 1',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
        },
        {
          'compressedFileSize': 150,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'errorMessage': '',
          'file': utf8.encode(fileContent),
          'name': 'Test Document 2',
          'originFileSize': 250,
          'status': DocumentStatus.created.name,
        },
      ];
      await db.delete('${defaultTablePrefix}_${Document.tableName}');
      const sql = '''
INSERT INTO ${defaultTablePrefix}_${Document.tableName} \$content''';
      await db.query(sql, bindings: {'content': documents});

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
          'name': 'doc$index',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
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
          'errorMessage': '',
          'name': 'Test Document 1',
          'originFileSize': 200,
          'status': DocumentStatus.created.name,
        },
        {
          'compressedFileSize': 150,
          'fileMimeType': 'text/plain',
          'contentMimeType': 'text/plain',
          'errorMessage': '',
          'name': 'Test Document 2',
          'originFileSize': 250,
          'status': DocumentStatus.created.name,
        },
      ];
      await db.delete('${defaultTablePrefix}_${Document.tableName}');
      const sql = '''
INSERT INTO ${defaultTablePrefix}_${Document.tableName} \$content''';
      await db.query(sql, bindings: {'content': documents});

      // Act
      final result = await repository.getTotal(defaultTablePrefix);

      // Assert
      expect(result, equals(documents.length));
    });
  });

  group('getDocumentById', () {
    test('should return a document by id', () async {
      // Arrange
      const fileContent = 'Hello world!';
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        file: utf8.encode(fileContent),
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
      );
      final result =
          await repository.createDocument(defaultTablePrefix, document);
      final id = result.id;

      // Act
      final getDocumentById = await repository.getDocumentById(id!);

      // Assert
      expect(getDocumentById?.id, equals(id));
      expect(utf8.decode(getDocumentById!.file!.toList()), equals(fileContent));
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
      const fileContent = 'Hello world!';
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        file: utf8.encode(fileContent),
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
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
      const fileContent = 'Hello world!';
      final document = Document(
        id: '${defaultTablePrefix}_${Document.tableName}:1',
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        file: utf8.encode(fileContent),
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
      );

      // Act & Assert
      expect(await repository.updateDocument(document), isNull);
    });

    test('should update document status', () async {
      // Arrange
      const document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
      );
      final created =
          await repository.createDocument(defaultTablePrefix, document);

      final updateStatus = created.copyWith(
        status: DocumentStatus.completed,
      );

      // Act
      final result = await repository.updateDocumentStatus(updateStatus);
      final updatedResult = await repository.getDocumentById(created.id!);

      // Assert
      expect(result?.status, equals(DocumentStatus.completed));
      expect(updatedResult?.updated?.isAfter(updatedResult.created!), isTrue);
    });
  });

  group('deleteDocument', () {
    test('should delete document', () async {
      // Arrange

      const document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        errorMessage: '',
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
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
