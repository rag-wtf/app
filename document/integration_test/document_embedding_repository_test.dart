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
    embeddingRepository = EmbeddingRepository(db: db);
    documentEmbeddingRepository = DocumentEmbeddingRepository(db: db);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(await documentRepository.isSchemaCreated(), isFalse);
      expect(await embeddingRepository.isSchemaCreated(), isFalse);
      expect(await documentEmbeddingRepository.isSchemaCreated(), isFalse);
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        (txn) async {
          if (!await documentRepository.isSchemaCreated()) {
            await documentRepository.createSchema(txn);
          }
          if (!await embeddingRepository.isSchemaCreated()) {
            await embeddingRepository.createSchema(txn);
          }
          if (!await documentEmbeddingRepository.isSchemaCreated()) {
            await documentEmbeddingRepository.createSchema(txn);
          }
        },
      );

      // Assert
      //final results = List<List<dynamic>>.from(txnResults! as List);
      //expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
      expect(await documentRepository.isSchemaCreated(), isTrue);
      expect(await embeddingRepository.isSchemaCreated(), isTrue);
      expect(await documentEmbeddingRepository.isSchemaCreated(), isTrue);
    });
  });

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
    final txnResults = await db.transaction(
      (txn) async {
        await documentRepository.createDocument(document, txn);
        await embeddingRepository.createEmbedding(embedding, txn);
        await documentEmbeddingRepository.createDocumentEmbedding(
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
    expect(await db.select('DocumentEmbedding'), hasLength(1));

    // Clean up
    await db.delete('Document');
    await db.delete('Embedding');
  });

  test('should create document embeddings', () async {
    // Arrange
    final document = Document(
      id: 'Document:${Ulid()}',
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
        id: 'Embedding:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
        tokensCount: 4,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
        tokensCount: 5,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
        tokensCount: 15,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
        tokensCount: 7,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
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
        await documentRepository.createDocument(document, txn);
        await embeddingRepository.createEmbeddings(embeddings, txn);
        await documentEmbeddingRepository.createDocumentEmbeddings(
          documentEmbeddings,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('DocumentEmbedding'),
      hasLength(documentEmbeddings.length),
    );

    // Clean up
    await db.delete('Document');
    await db.delete('Embedding');
  });

  test('should retrieve embeddings of given document Id', () async {
    // Arrange
    final document1 = Document(
      id: 'Document:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      tokensCount: 10,
      created: DateTime.now(),
      errorMessage: '',
      name: 'Document 1',
      originFileSize: 200,
      status: 'active',
      updated: DateTime.now(),
    );

    // Arrange
    final document2 = Document(
      id: 'Document:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      tokensCount: 10,
      created: DateTime.now(),
      errorMessage: '',
      name: 'Document 2',
      originFileSize: 200,
      status: 'active',
      updated: DateTime.now(),
    );

    final embeddings1 = [
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
        tokensCount: 4,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
        tokensCount: 5,
      ),
    ];
    final embeddings2 = [
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
        tokensCount: 15,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
        tokensCount: 7,
      ),
      Embedding(
        id: 'Embedding:${Ulid()}',
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
        await documentRepository.createDocument(document1, txn);
        await documentRepository.createDocument(document2, txn);
        await embeddingRepository.createEmbeddings(embeddings1, txn);
        await embeddingRepository.createEmbeddings(embeddings2, txn);
        await documentEmbeddingRepository.createDocumentEmbeddings(
          documentEmbeddings1,
          txn,
        );
        await documentEmbeddingRepository.createDocumentEmbeddings(
          documentEmbeddings2,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await documentEmbeddingRepository
          .getAllEmbeddingsOfDocument(document2.id!),
      hasLength(documentEmbeddings2.length),
    );

    // Clean up
    await db.delete('Document');
    await db.delete('Embedding');
  });
}
