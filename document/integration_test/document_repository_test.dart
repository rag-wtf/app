import 'dart:convert';

import 'package:document/document.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DocumentRepository repository;
  final db = Surreal();

  setUpAll(() async {
    await db.connect('mem://');
    await db.use(ns: 'test', db: 'test');
    repository = DocumentRepository(db: db);
    await repository.createSchema();
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
        status: 'active',
        updated: DateTime.now(),
        items: [
          DocumentItem(
            content: 'apple',
            embedding: testData['apple']!,
            metadata: {'id': 'customId1'},
            tokensCount: 4,
          ),
          DocumentItem(
            content: 'ten',
            embedding: testData['ten']!,
            metadata: {'id': 'customId2'},
            tokensCount: 5,
          ),
          DocumentItem(
            content: 'twenty',
            embedding: testData['twenty']!,
            metadata: {'id': 'customId3'},
            tokensCount: 15,
          ),
          DocumentItem(
            content: 'two',
            embedding: testData['two']!,
            metadata: {'id': 'customId4'},
            tokensCount: 7,
          ),
          DocumentItem(
            content: 'banana',
            embedding: testData['banana']!,
            metadata: {'id': 'customId5'},
            tokensCount: 10,
          ),
        ],
      );

      // Act
      final result = await repository.createDocument(document);

      // Assert
      expect(result.id, isNotNull);
      expect(result.items, hasLength(5));

      // retrieve with cosine similarity search
      print(
        await db.query(
          '''
          SELECT id, items.*.content, 
          vector::similarity::cosine(items.*.embedding, ${jsonEncode(listAllFruits)}) AS score
          FROM Document
          ORDER BY score DESC
          LIMIT 3;
        ''',
        ),
      );
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
        status: 'active',
        updated: DateTime.now(),
      );

      // Act
      final result = await repository.createDocument(document);

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
          'status': 'active',
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
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
        created: DateTime.now(),
        errorMessage: '',
        file: 'base64 encoded string',
        name: 'Test Document',
        originFileSize: 200,
        status: 'active',
        updated: DateTime.now(),
      );
      final result = await repository.createDocument(document);
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
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
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
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
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
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        tokensCount: 10,
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
