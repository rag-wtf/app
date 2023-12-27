import 'package:document/document.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DocumentService documentService;
  final db = Surreal();

  setUpAll(() async {
    await db.connect('mem://');
    await db.use(ns: 'test', db: 'test');
    documentService = DocumentService(db: db);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await documentService.isSchemaCreated(defaultTablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      if (!await documentService.isSchemaCreated(defaultTablePrefix)) {
        await documentService.createSchema(defaultTablePrefix);
      }

      // Assert
      expect(await documentService.isSchemaCreated(defaultTablePrefix), isTrue);
    });
  });

  test('should create document embeddings', () async {
    // Arrange
    final document = Document(
      id: '${defaultTablePrefix}_${Document.tableName}:${Ulid()}',
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
    );

    final embeddings = [
      Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
        tokensCount: 4,
      ),
      Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
        tokensCount: 5,
      ),
      Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
        tokensCount: 15,
      ),
      Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
        tokensCount: 7,
      ),
      Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
        tokensCount: 10,
      ),
    ];

    // Act
    final txnResults = await documentService.createDocumentEmbeddings(
      defaultTablePrefix,
      document,
      embeddings,
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${defaultTablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(embeddings.length),
    );

    // Clean up
    await db.delete('${defaultTablePrefix}_${Document.tableName}');
    await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
  });
}
