import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';
import 'test_data.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  final db = locator<Surreal>();
  final documentRepository = locator<DocumentRepository>();
  final embeddingRepository = locator<EmbeddingRepository>();
  final documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();

  setUpAll(() async {
    await Future<void>.delayed(const Duration(seconds: 3));
  });
  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await documentRepository.isSchemaCreated(defaultTablePrefix),
        isFalse,
      );
      expect(
        await embeddingRepository.isSchemaCreated(defaultTablePrefix),
        isFalse,
      );
      expect(
        await documentEmbeddingRepository.isSchemaCreated(defaultTablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        (txn) async {
          if (!await documentRepository.isSchemaCreated(defaultTablePrefix)) {
            await documentRepository.createSchema(defaultTablePrefix, txn);
          }
          if (!await embeddingRepository.isSchemaCreated(defaultTablePrefix)) {
            await embeddingRepository.createSchema(defaultTablePrefix, txn);
          }
          if (!await documentEmbeddingRepository
              .isSchemaCreated(defaultTablePrefix)) {
            await documentEmbeddingRepository.createSchema(
              defaultTablePrefix,
              txn,
            );
          }
        },
      );

      // Assert
      expect(
        await documentRepository.isSchemaCreated(defaultTablePrefix),
        isTrue,
      );
      expect(
        await embeddingRepository.isSchemaCreated(defaultTablePrefix),
        isTrue,
      );
      expect(
        await documentEmbeddingRepository.isSchemaCreated(defaultTablePrefix),
        isTrue,
      );
    });
  });

  test('should create document embedding', () async {
    // Arrange
    final ulid = Ulid();
    final document = Document(
      id: '${defaultTablePrefix}_${Document.tableName}:$ulid',
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
    final embedding = Embedding(
      id: '${defaultTablePrefix}_${Embedding.tableName}:${Ulid()}',
      content: 'apple',
      embedding: testData['apple']!,
      tokensCount: 4,
    );

    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await documentRepository.createDocument(
          defaultTablePrefix,
          document,
          txn,
        );
        await embeddingRepository.createEmbedding(
          defaultTablePrefix,
          embedding,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbedding(
          defaultTablePrefix,
          DocumentEmbedding(
            documentId: document.id!,
            embeddingId: embedding.id!,
          ),
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${defaultTablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(1),
    );

    // Clean up
    await db.delete('${defaultTablePrefix}_${Document.tableName}');
    await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
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
      status: DocumentStatus.created,
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

    final documentEmbeddings = <DocumentEmbedding>[];
    for (final embedding in embeddings) {
      documentEmbeddings.add(
        DocumentEmbedding(
          documentId: document.id!,
          embeddingId: embedding.id!,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await documentRepository.createDocument(
          defaultTablePrefix,
          document,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          defaultTablePrefix,
          embeddings,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          defaultTablePrefix,
          documentEmbeddings,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${defaultTablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(documentEmbeddings.length),
    );

    // Clean up
    await db.delete('${defaultTablePrefix}_${Document.tableName}');
    await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
  });

  test('should retrieve embeddings of given document Id', () async {
    // Arrange
    final document1 = Document(
      id: '${defaultTablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      tokensCount: 10,
      created: DateTime.now(),
      errorMessage: '',
      name: 'Document 1',
      originFileSize: 200,
      status: DocumentStatus.created,
      updated: DateTime.now(),
    );

    // Arrange
    final document2 = Document(
      id: '${defaultTablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      tokensCount: 10,
      created: DateTime.now(),
      errorMessage: '',
      name: 'Document 2',
      originFileSize: 200,
      status: DocumentStatus.created,
      updated: DateTime.now(),
    );

    final embeddings1 = [
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
    ];
    final embeddings2 = [
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

    final documentEmbeddings1 = <DocumentEmbedding>[];
    for (final embedding in embeddings1) {
      documentEmbeddings1.add(
        DocumentEmbedding(
          documentId: document1.id!,
          embeddingId: embedding.id!,
        ),
      );
    }

    final documentEmbeddings2 = <DocumentEmbedding>[];
    for (final embedding in embeddings2) {
      documentEmbeddings2.add(
        DocumentEmbedding(
          documentId: document2.id!,
          embeddingId: embedding.id!,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await documentRepository.createDocument(
          defaultTablePrefix,
          document1,
          txn,
        );
        await documentRepository.createDocument(
          defaultTablePrefix,
          document2,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          defaultTablePrefix,
          embeddings1,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          defaultTablePrefix,
          embeddings2,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          defaultTablePrefix,
          documentEmbeddings1,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          defaultTablePrefix,
          documentEmbeddings2,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await documentEmbeddingRepository.getAllEmbeddingsOfDocument(
        defaultTablePrefix,
        document2.id!,
      ),
      hasLength(documentEmbeddings2.length),
    );

    // Clean up
    await db.delete('${defaultTablePrefix}_${Document.tableName}');
    await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
  });
}
