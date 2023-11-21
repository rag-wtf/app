import 'dart:convert';

import 'package:document/document.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DocumentRepository documentRepository;
  late EmbeddingRepository embeddingRepository;
  late DocumentEmbeddingRepository documentEmbeddingRepository;
  final db = Surreal();

  setUpAll(() async {
    await db.connect('mem://');
    await db.use(ns: 'test', db: 'test');
    documentRepository = DocumentRepository(db: db);
    await documentRepository.createSchema();
    embeddingRepository = EmbeddingRepository(db: db);
    await embeddingRepository.createSchema();
    documentEmbeddingRepository = DocumentEmbeddingRepository(db: db);
    await documentEmbeddingRepository.createSchema();
  });

  group('createDocumentEmbedding', () {
    test('should create document embedding', () async {
      // Arrange
      final ulid = Ulid();
      final document = Document(
        id: 'Document:$ulid',
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
      final embedding = Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        tokensCount: 4,
      );

      // Act
      final txnResult = await db.transaction((txn) async {
        await documentRepository.createDocument(document, txn);
        await embeddingRepository.createEmbedding(embedding, txn);
        await documentEmbeddingRepository.createDocumentEmbedding(
          DocumentEmbedding(
            documentId: document.id!,
            embeddingId: embedding.id!,
          ),
          txn,
        );
      });

      // Assert
      print('txnResult $txnResult');
      expect(await db.select('DocumentEmbedding'), hasLength(1));

      // Clean up
      await db.delete('Document');
      await db.delete('Embedding');
    });

    /*test('should have validation errors', () async {
      // Arrange
      final embedding = Embedding(
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
        tokensCount: 4,
      );

      // Act
      final payload = embedding.toJson();
      // ignore: cascade_invocations
      payload.remove('content');
      final result = Embedding.validate(payload);

      // Assert
      expect(
        result?.first.message.startsWith('required prop missing: content'),
        isTrue,
      );
    });*/
  });
}
