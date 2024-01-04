import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';
import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final documentRepository = locator<DocumentRepository>();
  final embeddingRepository = locator<EmbeddingRepository>();
  final documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();
  const tablePrefix = 'doc_emb';

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await documentRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await embeddingRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await documentEmbeddingRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        (txn) async {
          if (!await documentRepository.isSchemaCreated(tablePrefix)) {
            await documentRepository.createSchema(tablePrefix, txn);
          }
          if (!await embeddingRepository.isSchemaCreated(tablePrefix)) {
            await embeddingRepository.createSchema(tablePrefix, txn);
          }
          if (!await documentEmbeddingRepository.isSchemaCreated(tablePrefix)) {
            await documentEmbeddingRepository.createSchema(
              tablePrefix,
              txn,
            );
          }
        },
      );

      // Assert
      expect(
        await documentRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await embeddingRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await documentEmbeddingRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
    });
  });

  test('should create document embedding', () async {
    // Arrange
    final ulid = Ulid();
    final document = Document(
      id: '${tablePrefix}_${Document.tableName}:$ulid',
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
      id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
      content: 'apple',
      embedding: testData['apple'],
      tokensCount: 4,
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await documentRepository.createDocument(
          tablePrefix,
          document,
          txn,
        );
        await embeddingRepository.createEmbedding(
          tablePrefix,
          embedding,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbedding(
          tablePrefix,
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
      await db.select('${tablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(1),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Document.tableName}');
    await db.delete('${tablePrefix}_${Embedding.tableName}');
  });

  test('should create document embeddings', () async {
    // Arrange
    final document = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
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
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple'],
        metadata: {'id': 'customId1'},
        tokensCount: 4,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten'],
        metadata: {'id': 'customId2'},
        tokensCount: 5,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty'],
        metadata: {'id': 'customId3'},
        tokensCount: 15,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two'],
        metadata: {'id': 'customId4'},
        tokensCount: 7,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana'],
        metadata: {'id': 'customId5'},
        tokensCount: 10,
        created: DateTime.now(),
        updated: DateTime.now(),
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
          tablePrefix,
          document,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          tablePrefix,
          documentEmbeddings,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(documentEmbeddings.length),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Document.tableName}');
    await db.delete('${tablePrefix}_${Embedding.tableName}');
  });

  test('should retrieve embeddings of given document Id', () async {
    // Arrange
    final document1 = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
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
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
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
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple'],
        metadata: {'id': 'customId1'},
        tokensCount: 4,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten'],
        metadata: {'id': 'customId2'},
        tokensCount: 5,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
    ];
    final embeddings2 = [
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty'],
        metadata: {'id': 'customId3'},
        tokensCount: 15,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two'],
        metadata: {'id': 'customId4'},
        tokensCount: 7,
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana'],
        metadata: {'id': 'customId5'},
        tokensCount: 10,
        created: DateTime.now(),
        updated: DateTime.now(),
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
          tablePrefix,
          document1,
          txn,
        );
        await documentRepository.createDocument(
          tablePrefix,
          document2,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings1,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings2,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          tablePrefix,
          documentEmbeddings1,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          tablePrefix,
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
        tablePrefix,
        document2.id!,
      ),
      hasLength(documentEmbeddings2.length),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Document.tableName}');
    await db.delete('${tablePrefix}_${Embedding.tableName}');
  });
}
