document/integration_test/document_embedding_repository_test.dart
```dart
import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';
import 'test_data.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final documentRepository = locator<DocumentRepository>();
  final embeddingRepository = locator<EmbeddingRepository>();
  final documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();
  const tablePrefix = 'doc_emb';

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

  tearDown(() async {
    await documentRepository.deleteAllDocuments(tablePrefix);
    await embeddingRepository.deleteAllEmbeddings(tablePrefix);
  });

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
            await embeddingRepository.createSchema(tablePrefix, '384', txn);
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
      errorMessage: '',
      name: 'Test Document',
      originFileSize: 200,
      status: DocumentStatus.created,
    );
    final embedding = Embedding(
      id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
      content: 'apple',
      embedding: testData['apple']!,
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
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${DocumentEmbedding.tableName}'),
      isNotNull,
    );
  });

  test('should create document embeddings', () async {
    // Arrange
    final document = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      name: 'Test Document',
      originFileSize: 200,
      status: DocumentStatus.created,
    );

    final embeddings = [
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
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
    final results = txnResults! as List;
    expect(
      results.every(
        (sublist) => sublist is Iterable
            ? sublist.isNotEmpty
            : (sublist as Map).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      await db.select('${tablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(documentEmbeddings.length),
    );
  });

  test('should retrieve embeddings of given document Id', () async {
    // Arrange
    final document1 = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      errorMessage: '',
      name: 'Document 1',
      originFileSize: 200,
      status: DocumentStatus.created,
    );

    // Arrange
    final document2 = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      errorMessage: '',
      name: 'Document 2',
      originFileSize: 200,
      status: DocumentStatus.created,
    );

    final embeddings1 = [
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      ),
    ];
    final embeddings2 = [
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
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
    final results = txnResults! as List;
    expect(
      results.every(
        (sublist) => sublist is Iterable
            ? sublist.isNotEmpty
            : (sublist as Map).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      await documentEmbeddingRepository.getAllEmbeddingsOfDocument(
        tablePrefix,
        document2.id!,
      ),
      hasLength(documentEmbeddings2.length),
    );
  });
}
```

document/integration_test/document_service_test.dart
```dart
import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/document_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

import 'test_data.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final documentService = locator<DocumentService>();
  final repository = locator<DocumentRepository>();
  const tablePrefix = 'doc_service';

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
      expect(
        await documentService.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      if (!await documentService.isSchemaCreated(tablePrefix)) {
        await documentService.createSchema(tablePrefix, '384');
      }

      // Assert
      expect(await documentService.isSchemaCreated(tablePrefix), isTrue);
    });
  });

  test('should update document and create embeddings', () async {
    // Arrange
    final document = Document(
      id: '${tablePrefix}_${Document.tableName}:${Ulid()}',
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      name: 'Test Document',
      originFileSize: 200,
      status: DocumentStatus.created,
    );

    final embeddings = [
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
      ),
      Embedding(
        id: '${tablePrefix}_${Embedding.tableName}:${Ulid()}',
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
      ),
    ];

    // Act
    final txnResults = await documentService.updateDocumentAndCreateEmbeddings(
      tablePrefix,
      document,
      embeddings,
    );

    // Assert
    final results = txnResults! as List;
    expect(
      results.every(
        (sublist) => sublist is Iterable
            ? sublist.isNotEmpty
            : (sublist as Map).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      await db.select('${tablePrefix}_${DocumentEmbedding.tableName}'),
      hasLength(embeddings.length),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Document.tableName}');
    await db.delete('${tablePrefix}_${Embedding.tableName}');
  });

  test('get document list with total', () async {
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
    await db.delete('${tablePrefix}_${Document.tableName}');
    final sql = '''
INSERT INTO ${tablePrefix}_${Document.tableName} ${jsonEncode(documents)}''';
    await db.query(sql);

    // Act
    const pageSize = 2;
    final page1 = await documentService.getDocumentList(
      tablePrefix,
      page: 0,
      pageSize: pageSize,
    );
    final page2 = await documentService.getDocumentList(
      tablePrefix,
      page: 1,
      pageSize: pageSize,
    );
    final page3 = await documentService.getDocumentList(
      tablePrefix,
      page: 2,
      pageSize: pageSize,
    );

    // Assert
    expect(page1.items, hasLength(pageSize));
    expect(page1.total, equals(documents.length));
    expect(page1.items[0].name, equals('doc4'));
    expect(page1.items[1].name, equals('doc3'));

    expect(page2.items, hasLength(pageSize));
    expect(page2.total, equals(documents.length));
    expect(page2.items[0].name, equals('doc2'));
    expect(page2.items[1].name, equals('doc1'));

    expect(page3.items, hasLength(1));
    expect(page3.total, equals(documents.length));
    expect(page3.items[0].name, equals('doc0'));

    // Clean up
    await db.delete('${tablePrefix}_${Document.tableName}');
  });

  test('create document and get document by id', () async {
    // Arrange
    const str = 'Hello, World!';
    final bytes = utf8.encode(str);
    final document = Document(
      compressedFileSize: 0,
      fileMimeType: 'text/plain',
      name: 'test',
      originFileSize: bytes.length,
      status: DocumentStatus.created,
      byteData: [bytes],
    );

    // Act
    final createdDocument =
        await documentService.createDocument(tablePrefix, document);
    final retrievedDocument =
        await documentService.getDocumentById(createdDocument.id!);
    final content = await documentService
        .convertByteDataToString(retrievedDocument!.byteData!);

    // Assert
    expect(content, equals(str));
  });

  group('should update document status and date', () {
    test('updateDocumentIndexingStatus', () async {
      final document = Document(
        compressedFileSize: 100,
        fileMimeType: 'text/plain',
        contentMimeType: 'text/plain',
        file: utf8.encode('Hello World!'),
        name: 'Test Document',
        originFileSize: 200,
        status: DocumentStatus.created,
      );
      final created =
          await repository.createDocument(defaultTablePrefix, document);
      final oldSplitted = created.splitted;
      final documentItem = DocumentItem(defaultTablePrefix, created);

      // Act
      await documentService.updateDocumentIndexingStatus(documentItem);

      // Assert
      expect(documentItem.item.status, equals(DocumentStatus.indexing));
      expect(documentItem.item.splitted!.isAfter(oldSplitted!), isTrue);
    });
  });

  test('updateDocumentDoneStatus', () async {
    final document = Document(
      compressedFileSize: 100,
      fileMimeType: 'text/plain',
      contentMimeType: 'text/plain',
      file: utf8.encode('Hello World!'),
      name: 'Test Document',
      originFileSize: 200,
      status: DocumentStatus.created,
    );
    final created =
        await repository.createDocument(defaultTablePrefix, document);
    final oldDone = created.done;
    final documentItem = DocumentItem(defaultTablePrefix, created);
    const errorMessage = 'Failed to update status';
    // Act
    await documentService.updateDocumentDoneStatus(
      documentItem,
      DocumentStatus.failed,
      errorMessage,
    );

    // Assert
    expect(documentItem.item.status, equals(DocumentStatus.failed));
    expect(documentItem.item.errorMessage, equals(errorMessage));
    expect(documentItem.item.done!.isAfter(oldDone!), isTrue);
  });
}
```

document/integration_test/all_tests.dart
```dart
import 'package:document/src/app/app.locator.dart';
import 'package:logger/logger.dart';

import 'document_embedding_repository_test.dart'
    as document_embedding_repository;
import 'document_repository_test.dart' as document_repository;
import 'document_service_test.dart' as document_service;
import 'embedding_repository_test.dart' as embedding_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  document_repository.main(wasm: wasm);
  embedding_repository.main(wasm: wasm);
  document_embedding_repository.main(wasm: wasm);
  document_service.main(wasm: wasm);
}
```

document/integration_test/document_repository_test.dart
```dart
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
      final id = result.id!;

      // Act
      final getDocumentById = await repository.getDocumentById(id);

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
```

document/integration_test/embedding_repository_test.dart
```dart
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

import 'test_data.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<EmbeddingRepository>();

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

  tearDown(() async {
    await repository.deleteAllEmbeddings(defaultTablePrefix);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isFalse);
    });

    test('should create schema and return true', () async {
      // Arrange
      if (!await repository.isSchemaCreated(defaultTablePrefix)) {
        await repository.createSchema(defaultTablePrefix, '384');
      }
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isTrue);
    });
  });

  group('redefineEmbeddingIndex', () {
    test('should create embedding of 4 dimensions', () async {
      // Arrange
      if (!await repository.isSchemaCreated(defaultTablePrefix)) {
        await repository.createSchema(defaultTablePrefix, '4');
      } else {
        await repository.redefineEmbeddingIndex(defaultTablePrefix, '4');
      }

      const embedding = Embedding(
        content: 'apple',
        embedding: [1.1, 2.2, 3.3, 4.4],
        metadata: {'id': 'customId1'},
      );

      // Act
      final result =
          await repository.createEmbedding(defaultTablePrefix, embedding);

      // Assert
      expect(result.id, isNotNull);

      // Clean up
      await repository.deleteAllEmbeddings(defaultTablePrefix);
      await repository.redefineEmbeddingIndex(defaultTablePrefix, '384');
    });

    test('should return cannot change dimensions message', () async {
      // Arrange
      final embedding = Embedding(
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      );
      await repository.createEmbedding(defaultTablePrefix, embedding);
      const expected = '''
Cannot change dimensions, there are existing embeddings in the database.''';

      // Act
      final result =
          await repository.redefineEmbeddingIndex(defaultTablePrefix, '4');

      // Assert
      expect(result, equals(expected));
    });

    test('should throw an incorrect dimension error', () async {
      // Arrange
      const embedding = Embedding(
        content: 'apple',
        embedding: [1.1, 2.2, 3.3, 4.4],
        metadata: {'id': 'customId1'},
      );

      // Act & Assert
      expect(
        () async => repository.createEmbedding(defaultTablePrefix, embedding),
        throwsA(
          predicate(
            (e) => e
                .toString()
                .contains('ResponseError: Incorrect vector dimension (4)'),
          ),
        ),
      );
    });
  });
  group('createEmbedding', () {
    test('should create embedding', () async {
      // Arrange
      final embedding = Embedding(
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      );

      // Act
      final result =
          await repository.createEmbedding(defaultTablePrefix, embedding);

      // Assert
      expect(result.id, isNotNull);
    });
  });

  group('createEmbeddings', () {
    test('should create embeddings', () async {
      // Arrange
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: testData['apple']!,
          metadata: {'id': 'customId1'},
        ),
        Embedding(
          content: 'ten',
          embedding: testData['ten']!,
          metadata: {'id': 'customId2'},
        ),
        Embedding(
          content: 'twenty',
          embedding: testData['twenty']!,
          metadata: {'id': 'customId3'},
        ),
        Embedding(
          content: 'two',
          embedding: testData['two']!,
          metadata: {'id': 'customId4'},
        ),
        Embedding(
          content: 'banana',
          embedding: testData['banana']!,
          metadata: {'id': 'customId5'},
        ),
      ];

      // Act
      final result =
          await repository.createEmbeddings(defaultTablePrefix, embeddings);

      // Assert
      expect(result, hasLength(embeddings.length));

      // Clean up
      await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
    });

    test('should create embeddings with content only', () async {
      // Arrange
      final emptyEmbedding = List<double>.filled(384, 0);
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'ten',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'twenty',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'two',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'banana',
          embedding: emptyEmbedding,
        ),
      ];

      // Act
      final result =
          await repository.createEmbeddings(defaultTablePrefix, embeddings);

      // Assert
      expect(result, hasLength(embeddings.length));

      // Clean up
      await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
    });
  });

  group('getAllEmbeddings', () {
    test('should return a list of embeddings', () async {
      // Arrange
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: testData['apple']!,
          metadata: {'id': 'customId1'},
        ).toJson(),
        Embedding(
          content: 'ten',
          embedding: testData['ten']!,
          metadata: {'id': 'customId2'},
        ).toJson(),
      ];
      const fullEmbeddingTableName =
          '${defaultTablePrefix}_${Embedding.tableName}';
      await db.delete(fullEmbeddingTableName);
      await db.query(
        'INSERT INTO $fullEmbeddingTableName ${jsonEncode(embeddings)}',
      );

      // Act
      final result = await repository.getAllEmbeddings(defaultTablePrefix);

      // Assert
      expect(result, hasLength(embeddings.length));
    });
  });

  group('getEmbeddingById', () {
    test('should return a embedding by id', () async {
      // Arrange
      final embedding = Embedding(
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      );
      final result =
          await repository.createEmbedding(defaultTablePrefix, embedding);
      final id = result.id!;

      // Act
      final getEmbeddingById = await repository.getEmbeddingById(id);

      // Assert
      expect(getEmbeddingById?.id, equals(id));
    });

    test('should not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Embedding.tableName}:1';

      // Act & Assert
      expect(await repository.getEmbeddingById(id), isNull);
    });
  });

  group('updateEmbeddings', () {
    test('should update embeddings', () async {
      final emptyEmbedding = List<double>.filled(384, 0);
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'ten',
          embedding: emptyEmbedding,
        ),
        Embedding(
          content: 'twenty',
          embedding: emptyEmbedding,
        ),
      ];
      final results =
          await repository.createEmbeddings(defaultTablePrefix, embeddings);
      results[0] = results[0].copyWith(embedding: testData['apple']!);
      results[1] = results[1].copyWith(embedding: testData['ten']!);
      results[2] = results[2].copyWith(embedding: testData['twenty']!);

      // Act
      final txnResults = await repository.updateEmbeddings(
        defaultTablePrefix,
        results,
      );

      txnResults.remove(txnResults.last); // remove rebuild index result

      // Assert
      expect(txnResults, hasLength(embeddings.length));

      expect(
        txnResults.every(
          (sublist) => sublist is Iterable
              ? sublist.isNotEmpty
              : (sublist as Map).isNotEmpty,
        ),
        isTrue,
      );
    });
  });

  group('updateEmbedding', () {
    test('should update embedding', () async {
      // Arrange
      final embedding = Embedding(
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      );
      final created =
          await repository.createEmbedding(defaultTablePrefix, embedding);

      // Act
      final updatedMetadata = {'id': 'customId3'};
      final updated = await repository.updateEmbedding(
        created.copyWith(metadata: updatedMetadata),
      );

      // Assert
      expect(updated?.metadata, equals(updatedMetadata));
    });

    test('should be null when the update embedding is not found', () async {
      // Arrange
      final embedding = Embedding(
        id: '${defaultTablePrefix}_${Embedding.tableName}:1',
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      );
      // Act & Assert
      expect(await repository.updateEmbedding(embedding), isNull);
    });
  });

  group('deleteEmbedding', () {
    test('should delete embedding', () async {
      // Arrange
      final embedding = Embedding(
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      );
      final created =
          await repository.createEmbedding(defaultTablePrefix, embedding);

      // Act
      final result = await repository.deleteEmbedding(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete embedding is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Embedding.tableName}:1';

      // Act & Assert
      expect(await repository.deleteEmbedding(id), isNull);
    });
  });

  group('similaritySearch', () {
    test('should retrieve appropriate embeddings', () async {
      // Clean up
      await db.delete('${defaultTablePrefix}_${Embedding.tableName}');

      // Arrange
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: testData['apple']!,
          metadata: {'id': 'customId1'},
        ),
        Embedding(
          content: 'ten',
          embedding: testData['ten']!,
          metadata: {'id': 'customId2'},
        ),
        Embedding(
          content: 'twenty',
          embedding: testData['twenty']!,
          metadata: {'id': 'customId3'},
        ),
        Embedding(
          content: 'two',
          embedding: testData['two']!,
          metadata: {'id': 'customId4'},
        ),
        Embedding(
          content: 'banana',
          embedding: testData['banana']!,
          metadata: {'id': 'customId5'},
        ),
      ];
      const k = 3;

      // Act
      await repository.createEmbeddings(defaultTablePrefix, embeddings);
      final result1 = await repository.similaritySearch(
        defaultTablePrefix,
        listAllNumbers,
        k,
        0.5,
      );
      final result2 = await repository.similaritySearch(
        defaultTablePrefix,
        listAllFruits,
        k,
        0.5,
      );

      // Assert
      expect(result1, hasLength(k));
      expect(
        result1.map((e) => e.content).toList(),
        equals(
          ['ten', 'twenty', 'apple'],
        ),
      );

      print('*** scores: ${result2.map((e) => e.score).toList()}');

      expect(result2, hasLength(k));
      expect(
        result2.map((e) => e.content).toList(),
        equals(
          ['banana', 'apple', 'ten'],
        ),
      );
    });
  });
}
```

document/test/helpers/test_helpers.dart
```dart
import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// @stacked-import
import 'test_helpers.mocks.dart';

final locator = StackedLocator.instance;

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DocumentApiService>(onMissingStub: OnMissingStub.returnDefault),

    MockSpec<BatchService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterApiService();
  getAndRegisterBatchService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockDocumentApiService getAndRegisterApiService() {
  _removeRegistrationIfExists<DocumentApiService>();
  final service = MockDocumentApiService();
  locator.registerSingleton<DocumentApiService>(service);
  return service;
}

MockBatchService getAndRegisterBatchService() {
  _removeRegistrationIfExists<BatchService>();
  final service = MockBatchService();
  locator.registerSingleton<BatchService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
```

document/test/viewmodels/embedding_dialog_model_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('EmbeddingDialogModel Tests -', () {
    setUp(registerServices);
    tearDown(locator.reset);
  });
}
```

document/test/src/services/api_service_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ApiServiceTest -', () {
    setUp(registerServices);
    tearDown(locator.reset);
  });
}
```

document/test/src/services/batch_service_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('BatchServiceTest -', () {
    setUp(registerServices);
    tearDown(locator.reset);
  });
}
```

document/test_driver/integration_test.dart
```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

document/lib/main.dart
```dart
import 'package:document/src/app/app.dialogs.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
```

document/lib/src/ui/widgets/document_list/document_item_widget.dart
```dart
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/ui/widgets/document_list/cancel_button_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_progress_indicator_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_status_widget.dart';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';

class DocumentItemWidget extends StatelessWidget {
  const DocumentItemWidget(
    this.documentItem, {
    super.key,
  });
  final DocumentItem documentItem;
  static const int megaBytes = 1024 * 1024;

  @override
  Widget build(BuildContext context) {
    final fileSizeInMB = documentItem.item.originFileSize / megaBytes;
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
            child: Row(
              children: [
                FileIcon(
                  documentItem.item.name,
                  size: 64,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documentItem.item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ), // Add some spacing between title and subtitle
                      Row(
                        children: [
                          Text(
                            '${fileSizeInMB.toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: DocumentProgressIndicatorWidget(
                                    documentItem.item.status,
                                    progress: documentItem.progress,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DocumentStatusWidget(item: documentItem.item),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (documentItem.item.status == DocumentStatus.splitting &&
              documentItem.cancelToken != null)
            CancelButtonWidget(documentItem.cancelToken!),
        ],
      ),
    );
  }
}
```

document/lib/src/ui/widgets/document_list/message_panel_widget.dart
```dart
import 'package:flutter/material.dart';

class MessagePanelWidget extends StatelessWidget {
  const MessagePanelWidget({required this.message, super.key, this.icon});
  final Icon? icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add a subtle shadow
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: icon,
              ),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

document/lib/src/ui/widgets/document_list/cancel_button_widget.dart
```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget(this.cancelToken, {super.key});
  final CancelToken cancelToken;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: cancelToken.cancel,
      ),
    );
  }
}
```

document/lib/src/ui/widgets/document_list/document_upload_zone_widget.dart
```dart
import 'package:flutter/material.dart';

class DocumentUploadZoneWidget extends StatelessWidget {
  const DocumentUploadZoneWidget({
    required this.message,
    required this.onTap,
    super.key,
    this.icon,
  });
  final Icon? icon;
  final String message;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: icon,
                ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

document/lib/src/ui/widgets/document_list/document_progress_indicator_widget.dart
```dart
import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:flutter/material.dart';

class DocumentProgressIndicatorWidget extends StatelessWidget {
  const DocumentProgressIndicatorWidget(
    this.status, {
    this.progress,
    super.key,
  });
  final DocumentStatus status;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    Widget uploadProgressIndicator;
    if (status == DocumentStatus.splitting) {
      uploadProgressIndicator = LinearProgressIndicator(
        value: progress,
        semanticsLabel: uploadProgressSemanticsLabel,
      );
    } else if (status == DocumentStatus.indexing) {
      uploadProgressIndicator = const LinearProgressIndicator(
        semanticsLabel: processProgressSemanticsLabel,
      );
    } else {
      uploadProgressIndicator = const SizedBox.shrink();
    }
    return uploadProgressIndicator;
  }
}
```

document/lib/src/ui/widgets/document_list/document_list_widget.dart
```dart
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class DocumentListWidget extends StatelessWidget {
  const DocumentListWidget({required this.viewModel, super.key});
  final DocumentListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return InfiniteList(
      itemCount: viewModel.items.length,
      isLoading: viewModel.isBusy,
      onFetchData: viewModel.fetchData,
      hasReachedMax: viewModel.hasReachedMax,
      itemBuilder: (context, index) {
        final documentItem = viewModel.items[index];
        return DocumentItemWidget(
          documentItem,
          key: ValueKey(documentItem.item.id),
        );
      },
    );
  }
}
```

document/lib/src/ui/widgets/document_list/document_status_widget.dart
```dart
import 'package:document/src/services/document.dart';
import 'package:flutter/material.dart';

class DocumentStatusWidget extends StatelessWidget {
  const DocumentStatusWidget({
    required this.item,
    super.key,
  });

  final Document item;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Widget status;
    switch (item.status) {
      case DocumentStatus.completed:
        textColor = Colors.green;

      case DocumentStatus.canceled:
        textColor = Colors.orange;

      case DocumentStatus.failed:
        textColor = Colors.red;

      case DocumentStatus.created:
      case DocumentStatus.pending:
      case DocumentStatus.splitting:
      case DocumentStatus.indexing:
        textColor = Colors.grey;
    }

    if (item.status == DocumentStatus.failed && item.errorMessage != null) {
      status = Tooltip(
        message: item.errorMessage,
        child: Row(
          children: [
            Text(
              item.status.name,
              style: TextStyle(
                color: textColor,
              ),
            ),
            Icon(
              Icons.help_outline,
              size: 16,
              color: textColor,
            ),
          ],
        ),
      );
    } else {
      status = Text(
        item.status.name,
        style: TextStyle(
          color: textColor,
        ),
      );
    }
    return status;
  }
}
```

document/lib/src/ui/views/startup/startup_view.dart
```dart
import 'package:document/src/ui/common/ui_helpers.dart';
import 'package:document/src/ui/views/startup/startup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'STACKED',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loading ...', style: TextStyle(fontSize: 16)),
                horizontalSpaceSmall,
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}
```

document/lib/src/ui/views/startup/startup_viewmodel.dart
```dart
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // Place anything here that needs to happen before we get into the application
  Future<void> runStartupLogic() async {
    // This is where you can make decisions on where your app should navigate
    // when you have custom startup logic
    await _navigationService.replaceWithDocumentListView(
      inPackage: true,
    );
  }
}
```

document/lib/src/ui/views/document_list/document_list_viewmodel.dart
```dart
import 'package:database/database.dart';
import 'package:document/src/app/app.dialogs.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/services/document_service.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DocumentListViewModel extends ReactiveViewModel {
  DocumentListViewModel(this.tablePrefix, {required this.inPackage});
  final String tablePrefix;
  final bool inPackage;

  final _documentService = locator<DocumentService>();
  final _settingService = locator<SettingService>();
  final _dialogService = locator<DialogService>();
  final _connectionSettingService = locator<ConnectionSettingService>();

  final _log = getLogger('DocumentListViewModel');

  List<DocumentItem> get items => _documentService.items;

  @override
  List<ListenableServiceMixin> get listenableServices => [_documentService];

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
    if (inPackage) {
      await connectDatabase();
      await _settingService.initialise(tablePrefix);
      final dimensions = _settingService.get(embeddingsDimensionsKey).value;
      await _documentService.initialise(tablePrefix, dimensions);
    }
  }

  Future<void> connectDatabase() async {
    var confirmed = false;
    if (!await _connectionSettingService.autoConnect()) {
      while (!confirmed) {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.connection,
          title: 'Connection',
          description: 'Create database connection',
        );

        confirmed = response?.confirmed ?? false;
      }
    }
  }

  bool get hasReachedMax => _documentService.hasReachedMax;

  Future<void> fetchData() async {
    await _documentService.fetchData(tablePrefix);
  }

  Future<void> addItem(Document? document) async {
    await _documentService.addItem(tablePrefix, document);
  }
}
```

document/lib/src/ui/views/document_list/document_list_view.dart
```dart
import 'dart:io';

import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_list_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_upload_zone_widget.dart';
import 'package:document/src/ui/widgets/document_list/message_panel_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mime_type/mime_type.dart';
import 'package:stacked/stacked.dart';

class DocumentListView extends StackedView<DocumentListViewModel> {
  const DocumentListView({
    super.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
  });
  final String tablePrefix;
  final bool inPackage;

  @override
  Widget builder(
    BuildContext context,
    DocumentListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Column(
        children: [
          const MessagePanelWidget(
            icon: Icon(Icons.info_outline),
            message: maximumFileSizeMessage,
          ),
          Expanded(
            child: Stack(
              children: [
                DocumentListWidget(
                  viewModel: viewModel,
                ),
                if (viewModel.items.isEmpty)
                  DocumentUploadZoneWidget(
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    message: uploadFileZoneMessage,
                    onTap: () async => viewModel.addItem(await pickFile()),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async => viewModel.addItem(await pickFile()),
              backgroundColor: Theme.of(context).cardColor,
              child: const Icon(Icons.file_upload_outlined),
            )
          : null,
    );
  }

  @override
  DocumentListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentListViewModel(
        tablePrefix,
        inPackage: inPackage,
      );

  @override
  Future<void> onViewModelReady(DocumentListViewModel viewModel) async {
    await viewModel.initialise();
  }

  Future<Document?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions.split(','),
      //allowMultiple: false,
      //withData: false,
      withReadStream: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    String? mimeType;
    var fileName = unknownFileName;
    if (kIsWeb) {
      // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-i-access-the-path-on-web
      final fileBytes =
          file.bytes; // Even withData: true, always null in web platform
      fileName = file.name;
      mimeType = lookupMimeType(fileName, headerBytes: fileBytes);
    } else {
      final filePath = file.path;
      if (filePath != null) {
        mimeType = lookupMimeType(filePath);
        fileName = filePath.split(Platform.pathSeparator).last;
      }
    }

    mimeType ??= mime(fileName);
    debugPrint('fileName $fileName, mimeType $mimeType');

    final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

    // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-do-i-use-withreadstream
    final fileReadStream = file.readStream;
    if (fileReadStream == null) {
      throw Exception(fileStreamExceptionMessage);
    }

    // Buffer the stream so that it can be process multiple times
    final fileData = await fileReadStream.toList();
    return Document(
      compressedFileSize: 0,
      fileMimeType: contentType!.mimeType,
      name: fileName,
      originFileSize: file.size,
      status: DocumentStatus.created,
      byteData: fileData,
    );
  }
}
```

document/lib/src/ui/dialogs/embedding/embedding_dialog_model.dart
```dart
import 'package:stacked/stacked.dart';

class EmbeddingDialogModel extends FormViewModel {}
```

document/lib/src/ui/dialogs/embedding/embedding_dialog.dart
```dart
import 'package:database/database.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/ui/common/ui_helpers.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.form.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog_model.dart';
import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@FormView(
  fields: [
    FormTextField(name: 'id'),
    FormTextField(name: 'content'),
    FormTextField(name: 'embedding'),
    FormTextField(name: 'metadata'),
    FormTextField(name: 'created'),
    FormTextField(name: 'updated'),
    FormTextField(name: 'score'),
  ],
)
class EmbeddingDialog extends StackedView<EmbeddingDialogModel>
    with $EmbeddingDialog {
  const EmbeddingDialog({
    required this.request,
    required this.completer,
    super.key,
  });
  final DialogRequest<dynamic> request;
  final void Function(DialogResponse<void>) completer;

  @override
  Widget builder(
    BuildContext context,
    EmbeddingDialogModel viewModel,
    Widget? child,
  ) {
    final isDense = MediaQuery.sizeOf(context).width < 600;
    return AdaptiveDialog(
      maxWidth: dialogMaxWidth,
      maxHeight: 600,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.title ??
                      idController.text
                          .substring(idController.text.indexOf(':') + 1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => completer(DialogResponse()),
                ),
              ],
            ),
            verticalSpaceTiny,
            if (viewModel.isBusy)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: [
                    /* InputField( 
                            isDense: isDense,
                            labelText: 'ID',
                            prefixIcon: Icon(
                              Icons.fingerprint,
                              color: iconColor,
                            ),
                            errorText: viewModel.idValidationMessage,
                            controller: idController,
                            textInputType: TextInputType.text,
                            readOnly: true,
                          ),
                          verticalSpaceTiny,
                          */
                    InputField(
                      isDense: isDense,
                      labelText: 'Content',
                      errorText: viewModel.contentValidationMessage,
                      controller: contentController,
                      textInputType: TextInputType.multiline,
                      readOnly: true,
                      maxLines: null,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Embedding',
                      errorText: viewModel.embeddingValidationMessage,
                      controller: embeddingController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Metadata',
                      errorText: viewModel.metadataValidationMessage,
                      controller: metadataController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Score',
                      errorText: viewModel.scoreValidationMessage,
                      controller: scoreController,
                      textInputType: TextInputType.number,
                      readOnly: true,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Created',
                      errorText: viewModel.createdValidationMessage,
                      controller: createdController,
                      textInputType: TextInputType.datetime,
                      readOnly: true,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Updated',
                      errorText: viewModel.updatedValidationMessage,
                      controller: updatedController,
                      textInputType: TextInputType.datetime,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  EmbeddingDialogModel viewModelBuilder(
    BuildContext context,
  ) =>
      EmbeddingDialogModel();

  @override
  Future<void> onViewModelReady(EmbeddingDialogModel viewModel) async {
    final embedding = request.data as Embedding;
    idController.text = embedding.id.toString();
    contentController.text = embedding.content;
    embeddingController.text = embedding.embedding.join(', ');
    metadataController.text = embedding.metadata.toString();
    createdController.text = embedding.created.toString();
    updatedController.text = embedding.updated.toString();
    if (embedding.score != null) {
      scoreController.text = embedding.score!.toStringAsFixed(2);
    }
  }
}
```

document/lib/src/constants.dart
```dart
const allowedExtensions = 'txt,pdf,html,md,ppt,pptx,doc,docx,epub,eml';
const unknownFileName = 'Unknown';
const fileStreamExceptionMessage = 'Cannot read file from null stream!';
const maximumFileSizeMessage = 'Max 10MB per file.';
const uploadFileZoneMessage = 'Click or tap here to upload';
const uploadProgressSemanticsLabel = 'upload progress';
const processProgressSemanticsLabel = 'process progress';
const defaultPageSize = 10;
const defaultAscendingOrder = false;
const chunkSizeQueryString = 'q_chunk_size';
const chunkOverlapQueryString = 'q_chunk_overlap';
```

document/lib/src/services/embedding_repository.dart
```dart
import 'dart:convert';

import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/embedding.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class EmbeddingRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('EmbeddingRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Embedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix,
    String dimensions, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Embedding.sqlSchema
        .replaceAll('{prefix}', tablePrefix)
        .replaceFirst('{dimensions}', dimensions);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<String?> redefineEmbeddingIndex(
    String tablePrefix,
    String dimensions,
  ) async {
    _log.d('redefineEmbeddingIndex($tablePrefix, $dimensions)');
    final sql = Embedding.redefineEmbeddingsMtreeIndex
        .replaceAll('{prefix}', tablePrefix)
        .replaceFirst('{dimensions}', dimensions);
    final total = await getTotal(tablePrefix);
    if (total > 0) {
      return '''
Cannot change dimensions, there are existing embeddings in the database.''';
    } else {
      await _db.query(sql);
      return null;
    }
  }

  Future<Object?> rebuildEmbeddingIndex(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    _log.d('rebuildEmbeddingIndex($tablePrefix)');
    final sql = Embedding.rebuildEmbeddingsMtreeIndex
        .replaceAll('{prefix}', tablePrefix);
    if (txn == null) {
      return _db.query(sql);
    } else {
      txn.query(sql);
      return null;
    }
  }

  Future<Embedding> createEmbedding(
    String tablePrefix,
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    final payload = embedding.toJson();
    final sql = '''
CREATE ONLY ${tablePrefix}_${Embedding.tableName} 
CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await _db.query(sql);

      return Embedding.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return embedding;
    }
  }

  Future<List<Embedding>> createEmbeddings(
    String tablePrefix,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    final payloads = embeddings.map((embedding) => embedding.toJson()).toList();
    final sql = 'INSERT INTO ${tablePrefix}_${Embedding.tableName} \$payloads;';
    final bindings = {'payloads': payloads};

    if (txn == null) {
      final results = (await _db.query(sql, bindings: bindings))! as List;

      return results
          .map(
            (result) => Embedding.fromJson(
              Map<String, dynamic>.from(
                result as Map,
              ),
            ),
          )
          .toList();
    } else {
      txn.query(sql, bindings: bindings);
      return embeddings;
    }
  }

  Future<List<Embedding>> getAllEmbeddings(String tablePrefix) async {
    final results = (await _db
        .query('SELECT * FROM ${tablePrefix}_${Embedding.tableName}'))! as List;
    return results
        .map(
          (result) => Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<Embedding?> getEmbeddingById(String id) async {
    final result = await _db.select(id);

    return result != null
        ? Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<List<dynamic>> updateEmbeddings(
    String tablePrefix,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      final results = (await _db.transaction(
        timeout: Duration(seconds: embeddings.length),
        (txn) async {
          for (final embedding in embeddings) {
            await updateEmbedding(
              embedding,
              txn,
            );
          }
          await rebuildEmbeddingIndex(tablePrefix, txn);
        },
      ))!;

      return results is Iterable ? results as List : [results];
    } else {
      for (final embedding in embeddings) {
        await updateEmbedding(
          embedding,
          txn,
        );
      }
      await rebuildEmbeddingIndex(tablePrefix, txn);
      return List.empty();
    }
  }

  Future<Embedding?> updateEmbedding(
    Embedding embedding, [
    Transaction? txn,
  ]) async {
    if (await _db.select(embedding.id!) == null) return null;

    final payload = embedding.toJson();
    final id = payload.remove('id') as String;
    final sql = 'UPDATE ONLY $id MERGE ${jsonEncode(payload)};';
    if (txn == null) {
      final result = await _db.query(sql);
      return Embedding.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return null;
    }
  }

  Future<Embedding?> deleteEmbedding(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
    double threshold,
  ) async {
    final sql = '''
SELECT * FROM (
  SELECT *, vector::similarity::cosine(embedding, $vector) AS score
  FROM ${tablePrefix}_${Embedding.tableName}
  WHERE embedding <$k> $vector
)
WHERE score >= $threshold
ORDER BY score DESC;
''';
    _log.d('sql $sql');
    final results = (await _db.query(
      sql,
    ))! as List;
    return results
        .map(
          (result) => Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Embedding.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return results.isEmpty ? 0 : (results.first as Map)['count'] as int;
  }

  Future<void> deleteAllEmbeddings(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Embedding.tableName}');
  }
}
```

document/lib/src/services/document_repository.dart
```dart
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class DocumentRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('DocumentRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Document.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Document.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Document> createDocument(
    String tablePrefix,
    Document document, [
    Transaction? txn,
  ]) async {
    final payload = document.toJson();
    if (document.file != null) {
      payload['file'] = document.file;
    }

    final fullTableName = '${tablePrefix}_${Document.tableName}';
    final sql = 'CREATE ONLY $fullTableName CONTENT \$content;';
    _log.d('txn: $txn, payload: $payload');
    if (txn == null) {
      final result = await _db.query(sql, bindings: {'content': payload});

      return Document.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql, bindings: {'content': payload});
      return document;
    }
  }

  Future<List<Document>> getAllDocuments(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final sql = '''
SELECT * FROM ${tablePrefix}_${Document.tableName} 
ORDER BY updated ${ascendingOrder ? 'ASC' : 'DESC'}
${page == null ? ';' : ' LIMIT $pageSize START ${page * pageSize};'}''';
    final results = (await _db.query(sql))! as List;
    return results
        .map(
          (result) => Document.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Document.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return results.isNotEmpty ? (results.first as Map)['count'] as int : 0;
  }

  Future<Document?> getDocumentById(String id) async {
    final result = await _db.select(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Document?> updateDocument(
    Document document, [
    Transaction? txn,
  ]) async {
    if (await _db.select(document.id!) == null) return null;
    final payload = document.toJson();
    final id = payload.remove('id') as String;
    final sql = 'UPDATE ONLY $id MERGE \$content;';
    _log.d('txn: $txn, id: $id, payload: $payload');
    if (txn == null) {
      final result = await _db.query(sql, bindings: {'content': payload});

      return Document.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql, bindings: {'content': payload});
      return null;
    }
  }

  Future<Document?> updateDocumentStatus(
    Document document, [
    Transaction? txn,
  ]) async {
    final sql = '''
UPDATE ONLY ${document.id} PATCH [
  {
      "op": "replace",
      "path": "/status",
      "value": "${document.status.name}"
  }
]
''';
    _log.d('txn: $txn, sql: $sql');
    if (txn == null) {
      final result = await _db.query(sql);
      return Document.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return null;
    }
  }

  Future<Document?> deleteDocument(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Document.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllDocuments(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Document.tableName}');
  }
}
```

document/lib/src/services/document_api_service.dart
```dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:http_parser/http_parser.dart';
import 'package:settings/settings.dart';

class DocumentApiService {
  final _gzipEncoder = locator<GZipEncoder>();
  final _batchService = locator<BatchService>();
  final _log = getLogger('DocumentApiService');

  Future<void> split(
    Dio dio,
    String url,
    DocumentItem documentItem,
    Future<void> Function(
      DocumentItem documentItem,
      DocumentStatus status,
    ) onUpdateDocumentStatus,
    void Function(
      DocumentItem documentItem,
      double progress,
    ) onProgress,
    Future<void> Function(
      DocumentItem documentItem,
      Map<String, dynamic>? responseData,
    ) onSplitCompleted,
    // ignore: prefer_void_to_null
    Future<Null> Function(DocumentItem documentItem, dynamic error) onError,
  ) async {
    final bytesLength = documentItem.item.byteData![0].length;
    _log.d('bytesLength $bytesLength');
    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(documentItem.item.byteData!),
      documentItem.item.byteData!.length,
      filename: documentItem.item.name,
      contentType: MediaType.parse(documentItem.item.fileMimeType),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    await dio.post<Map<String, dynamic>>(
      url,
      data: formData,
      cancelToken: documentItem.cancelToken,
      onSendProgress: (int sent, int total) async {
        if (documentItem.item.status == DocumentStatus.pending) {
          _log.d('updateDocumentStatus(DocumentStatus.splitting)');
          await onUpdateDocumentStatus(documentItem, DocumentStatus.splitting);
        }

        final progress = sent / total;
        onProgress(documentItem, progress);
      },
      onReceiveProgress: (int count, int total) async {
        /* The same code above works but not the following code?
        if (total == 0 && widgetModel.item.status == DocumentStatus.pending) {
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }
        */
        final progress = count * 0.01;
        onProgress(documentItem, progress);
      },
    ).then((response) async {
      await onSplitCompleted(documentItem, response.data).timeout(
        Duration(milliseconds: max(bytesLength * 3, 600 * 1000)),
      );
    }).catchError((dynamic error) {
      onError(documentItem, error);
    }).timeout(
      Duration(milliseconds: max(bytesLength * 3, 600 * 1000)),
    );
  }

  Future<List<List<double>>> index(
    Dio dio,
    String model,
    String apiUrl,
    String apiKey,
    List<String> chunkedTexts, {
    required int dimensions,
    int batchSize = 100,
    bool compressed = true,
  }) async {
    final embeddings = await _batchService.execute<String, List<double>>(
      chunkedTexts,
      batchSize,
      (values) async {
        // Send the batch and add the future to the list
        final response = await dio.post<Map<String, dynamic>>(
          apiUrl,
          options: Options(
            headers: {
              'Content-type': 'application/json',
              if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
            },
            requestEncoder: compressed ? gzipRequestEncoder : null,
            sendTimeout: const Duration(seconds: 600),
            receiveTimeout: const Duration(seconds: 600),
          ),
          data: {
            'model': model,
            'input': values,
            'dimensions': dimensions,
          },
        ).timeout(
          const Duration(seconds: 900),
        );

        final embeddingsDataMap = response.data;
        return List<Map<String, dynamic>>.from(
          embeddingsDataMap?['data'] as List,
        )
            .map(
              (item) => List<double>.from(
                item['embedding'] as List,
              ),
            )
            .toList();
      },
    );
    _log.d('embeddings.length = ${embeddings.length}');

    return embeddings;
  }

  List<int> gzipRequestEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }
}
```

document/lib/src/services/document_embedding.dart
```dart
import 'package:document/src/services/document.dart';
import 'package:document/src/services/embedding.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'document_embedding.freezed.dart';
part 'document_embedding.g.dart';

@Freezed(toJson: true)
sealed class DocumentEmbedding with _$DocumentEmbedding {
  const factory DocumentEmbedding({
    required String documentId,
    required String embeddingId,
    String? id,
  }) = _DocumentEmbedding;

  factory DocumentEmbedding.fromJson(Map<String, dynamic> json) {
    return DocumentEmbedding(
      id: json['id'].toString(),
      documentId: json['documentId'] as String,
      embeddingId: json['embeddingId'] as String,
    );
  }

  static const tableName = 'document_embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Document.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Embedding.tableName}>;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
```

document/lib/src/services/embedding.dart
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'embedding.freezed.dart';
part 'embedding.g.dart';

@Freezed(toJson: true)
sealed class Embedding with _$Embedding {
  const factory Embedding({
    required String content,
    required List<double> embedding,
    String? id,
    Object? metadata,
    @JsonKey(includeToJson: false) double? score,
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
  }) = _Embedding;

  factory Embedding.fromJson(Map<String, dynamic> json) {
    return Embedding(
      id: json['id'].toString(),
      content: json['content'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      score: (json['score'] as num?)?.toDouble(),
      metadata: json['metadata'],
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD content ON {prefix}_$tableName TYPE string;
DEFINE FIELD embedding ON {prefix}_$tableName TYPE array<float>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
$_defineEmbeddingsMtreeIndex
DEFINE EVENT {prefix}_${tableName}_updated ON TABLE {prefix}_$tableName 
WHEN \$event = "UPDATE" AND \$before.updated == \$after.updated THEN (
    UPDATE {prefix}_$tableName SET updated = time::now() WHERE id = \$after.id 
);
''';

  // 65535 is the maximum value of an unsigned 16-bit integer
  static const _defineEmbeddingsMtreeIndex = '''
DEFINE INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName 
FIELDS embedding MTREE DIMENSION {dimensions} DIST COSINE TYPE F32
CAPACITY 65535;
''';

  static const redefineEmbeddingsMtreeIndex = '''
REMOVE INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName;
$_defineEmbeddingsMtreeIndex
''';

  static const rebuildEmbeddingsMtreeIndex = '''
REBUILD INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName;
''';
}
```

document/lib/src/services/null_json_converters.dart
```dart
import 'package:json_annotation/json_annotation.dart';

class NullJsonConverter<T> extends JsonConverter<T, T> {
  const NullJsonConverter();

  @override
  T fromJson(T json) {
    return json;
  }

  @override
  T toJson(T object) {
    return object;
  }
}

class NullDateTimeJsonConverter extends NullJsonConverter<DateTime> {
  const NullDateTimeJsonConverter();
}
```

document/lib/src/services/batch_service.dart
```dart
import 'dart:math';

import 'package:document/src/app/app.logger.dart';

class BatchService {
  final _log = getLogger('BatchService');

  Future<List<TResult>> execute<TInput, TResult>(
    List<TInput> values,
    int batchSize,
    Future<List<TResult>> Function(
      List<TInput> values,
    ) batchFunction,
  ) async {
    final numBatches = (values.length / batchSize).ceil();
    final items = List<TResult>.empty(growable: true);

    for (var i = 0; i < numBatches; i++) {
      // Get the start and end indices of the current batch
      final start = i * batchSize;
      final end = min(start + batchSize, values.length);

      _log.d('start $start, end $end');

      // Get the current batch of items
      final batch = values.sublist(start, end);
      items.addAll(await batchFunction(batch));
    }

    return items;
  }
}
```

document/lib/src/services/date_time_json_converter.dart
```dart
import 'package:json_annotation/json_annotation.dart';

class DateTimeJsonConverter implements JsonConverter<DateTime, String> {
  const DateTimeJsonConverter();

  @override
  DateTime fromJson(String dateString) {
    return DateTime.parse(dateString);
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
```

document/lib/src/services/document.dart
```dart
// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@Freezed(toJson: true)
sealed class Document with _$Document {
  const factory Document({
    required int compressedFileSize,
    required String fileMimeType, // could be gzip file
    required String name,
    required int originFileSize,
    required DocumentStatus status,
    String? id,
    String? content,
    String? contentMimeType, // mime type of content of the gzip file
    @JsonKey(includeToJson: false) Uint8List? file,
    Object? metadata,
    String? errorMessage,
    @JSDateJsonConverter() DateTime? splitted,
    @JSDateJsonConverter() DateTime? done, // completed/failed/canceled
    @JsonKey(includeFromJson: false, includeToJson: false)
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<List<int>>? byteData,
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'].toString(),
      compressedFileSize: json['compressedFileSize'] as int,
      fileMimeType: json['fileMimeType'] as String,
      name: json['name'] as String,
      originFileSize: json['originFileSize'] as int,
      status: DocumentStatus.values.byName(json['status'] as String),
      content: json['content'] as String?,
      contentMimeType: json['contentMimeType'] as String?,
      file: json['file'] != null
          ? (json['file'] as ByteBuffer).asUint8List()
          : null,
      metadata: json['metadata'],
      errorMessage: json['errorMessage'] as String?,
      splitted: json['splitted'] as DateTime?,
      done: json['done'] as DateTime?,
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'documents';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD compressedFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD content ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD fileMimeType ON {prefix}_$tableName TYPE string;
DEFINE FIELD contentMimeType ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD errorMessage ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD file ON {prefix}_$tableName TYPE option<bytes>;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD originFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD status ON {prefix}_$tableName TYPE string;
DEFINE FIELD splitted ON {prefix}_$tableName TYPE datetime DEFAULT time::from::unix(0);
DEFINE FIELD done ON {prefix}_$tableName TYPE datetime DEFAULT time::from::unix(0);
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE EVENT {prefix}_${tableName}_updated ON TABLE {prefix}_$tableName 
WHEN \$event = "UPDATE" AND \$before.updated == \$after.updated THEN (
    UPDATE {prefix}_$tableName SET updated = time::now() WHERE id = \$after.id 
);
''';
}

enum DocumentStatus {
  created,
  pending,
  splitting,
  indexing,
  completed,
  failed,
  canceled,
}

class DocumentList {
  const DocumentList(this.items, this.total);
  final List<Document> items;
  final int total;
}
```

document/lib/src/services/document_item.dart
```dart
import 'package:dio/dio.dart';
import 'package:document/src/services/document.dart';

class DocumentItem {
  DocumentItem(
    this.tablePrefix,
    this.item, [
    this.progress,
    this.cancelToken,
  ]);

  String tablePrefix;
  Document item;
  double? progress;
  final CancelToken? cancelToken;
}
```

document/lib/src/services/document_service.dart
```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/constants.dart';
import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:mutex/mutex.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

class DocumentService with ListenableServiceMixin {
  DocumentService() {
    listenToReactiveValues([_items]);
  }
  final _dio = locator<Dio>();
  final _db = locator<Surreal>();
  final _documentRepository = locator<DocumentRepository>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _documentEmbeddingRepository = locator<DocumentEmbeddingRepository>();
  final _apiService = locator<DocumentApiService>();
  final _batchService = locator<BatchService>();
  final _settingService = locator<SettingService>();
  final _gzipEncoder = locator<GZipEncoder>();
  final _gzipDecoder = locator<GZipDecoder>();
  final _mutex = Mutex();

  int _total = -1;
  final _items = <DocumentItem>[];
  List<DocumentItem> get items => _items.toList();

  final _log = getLogger('DocumentService');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Document.tableName}') &&
        tables.containsKey('${tablePrefix}_${Embedding.tableName}') &&
        tables.containsKey('${tablePrefix}_${DocumentEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix,
    String dimensions, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await _db.transaction(
        (txn) async {
          await _documentRepository.createSchema(tablePrefix, txn);
          await _embeddingRepository.createSchema(tablePrefix, dimensions, txn);
          await _documentEmbeddingRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await _documentRepository.createSchema(tablePrefix, txn);
      await _embeddingRepository.createSchema(tablePrefix, dimensions, txn);
      await _documentEmbeddingRepository.createSchema(tablePrefix, txn);
    }
  }

  Future<void> initialise(String tablePrefix, String dimensions) async {
    if (!await isSchemaCreated(tablePrefix)) {
      await createSchema(tablePrefix, dimensions);
    }
    _total = -1;
    _items.clear();
  }

  bool get hasReachedMax {
    final reachedMax = _total > -1 && _items.length >= _total;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchData(String tablePrefix) async {
    final page = _items.length ~/ defaultPageSize;
    _log.d('page $page');
    final documentList = await getDocumentList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('documentList.total ${documentList.total}');
    if (documentList.total > 0 && documentList.total > _items.length) {
      _items.addAll(
        documentList.items
            .map(
              (item) => DocumentItem(tablePrefix, item),
            )
            .toList(),
      );
      _total = documentList.total;
      notifyListeners();
    }
  }

  Future<void> addItem(String tablePrefix, Document? document) async {
    if (document != null) {
      final createdDocument = await createDocument(tablePrefix, document);
      if (createdDocument.id != null) {
        final documentItem = DocumentItem(
          tablePrefix,
          createdDocument,
          0,
          CancelToken(),
        );
        _items.insert(0, documentItem);
        notifyListeners();
        _log.d('0. documentItem.hashCode ${documentItem.hashCode}');
        await _split(documentItem);
      }
    }
  }

  Future<void> clearData(
    String tablePrefix, {
    required bool clearSettings,
  }) async {
    _total = -1;
    _items.clear();
    await _documentRepository.deleteAllDocuments(tablePrefix);
    await _embeddingRepository.deleteAllEmbeddings(tablePrefix);
    if (clearSettings) {
      await _embeddingRepository.redefineEmbeddingIndex(
        tablePrefix,
        defaultEmbeddingsDimensions,
      );
    }
    notifyListeners();
  }

  Future<Object?> updateDocumentAndCreateEmbeddings(
    String tablePrefix,
    Document document,
    List<Embedding> embeddings, [
    Transaction? txn,
  ]) async {
    _log.d('***** start');
    Object? result;
    final documentEmbeddings = <DocumentEmbedding>[];
    for (final embedding in embeddings) {
      documentEmbeddings.add(
        DocumentEmbedding(
          documentId: document.id!,
          embeddingId: embedding.id!,
        ),
      );
    }

    if (txn == null) {
      result = await _db.transaction(
        showSql: true,
        (txn) async {
          await _documentRepository.updateDocument(
            document,
            txn,
          );
          await _embeddingRepository.createEmbeddings(
            tablePrefix,
            embeddings,
            txn,
          );
          await _documentEmbeddingRepository.createDocumentEmbeddings(
            tablePrefix,
            documentEmbeddings,
            txn,
          );
        },
      );
    } else {
      await _documentRepository.updateDocument(document, txn);
      await _embeddingRepository.createEmbeddings(tablePrefix, embeddings, txn);
      await _documentEmbeddingRepository.createDocumentEmbeddings(
        tablePrefix,
        documentEmbeddings,
        txn,
      );
    }

    _log.d('***** end');
    return result;
  }

  Future<Object?> _updateEmbeddings(
    String tablePrefix,
    List<Embedding> embeddings,
    List<List<double>> vectors, [
    Transaction? txn,
  ]) async {
    assert(
      embeddings.length == vectors.length,
      'embeddings(${embeddings.length}) != vectors(${vectors.length})',
    );
    for (var i = 0; i < embeddings.length; i++) {
      embeddings[i] = embeddings[i].copyWith(
        embedding: vectors[i],
      );
    }
    
    final batchSize = int.parse(
            _settingService.get(embeddingsDatabaseBatchSizeKey).value,
          );
    final batchResults = await _batchService.execute<Embedding, dynamic>(
        embeddings, batchSize, (values) async {
      return _embeddingRepository.updateEmbeddings(
        tablePrefix,
        values,
        txn,
      );
    });    
    return batchResults;
  }

  Future<Document> createDocument(String tablePrefix, Document document) async {
    final compressedFile = await _compressFile(
      document.byteData!.first,
    );
    final newDocument = document.copyWith(
      compressedFileSize: compressedFile.length,
      file: compressedFile,
    );
    return _documentRepository.createDocument(
      tablePrefix,
      newDocument,
    );
  }

  Future<Document?> getDocumentById(String id) async {
    var document = await _documentRepository.getDocumentById(id);

    if (document != null && document.file != null) {
      document = document.copyWith(
        byteData: [await _decompressFile(document.file!)],
      );
    }
    return document;
  }

  Future<String> convertByteDataToString(List<List<int>> byteData) async {
    final buffer = StringBuffer();
    await Stream.fromIterable(byteData)
        .transform(
          utf8.decoder,
        )
        .forEach(
          buffer.write,
        );
    return buffer.toString();
  }

  Future<List<Embedding>> similaritySearch(
    String tablePrefix,
    List<double> vector,
    int k,
    double threshold,
  ) async {
    return _embeddingRepository.similaritySearch(
      tablePrefix,
      vector,
      k,
      threshold,
    );
  }

  Future<DocumentList> getDocumentList(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final total = await _documentRepository.getTotal(tablePrefix);
    if (total > 0) {
      final items = await _documentRepository.getAllDocuments(
        tablePrefix,
        page: page,
        pageSize: pageSize,
        ascendingOrder: ascendingOrder,
      );
      return DocumentList(items, total);
    } else {
      return const DocumentList([], 0);
    }
  }

  bool _isGzFile(List<int> fileBytes) {
    return fileBytes[0] == 0x1f && fileBytes[1] == 0x8b;
  }

  /*
  Future<String> _compressFileToBase64(List<int> bytes) async {
    if (_isGzFile(bytes)) {
      return base64Encode(bytes);
    } else {
      return base64Encode(
        _gzipEncoder.encode(bytes)!,
      );
    }
  }
  */

  Future<Uint8List> _compressFile(List<int> bytes) async {
    if (_isGzFile(bytes)) {
      return Uint8List.fromList(bytes);
    } else {
      return Uint8List.fromList(_gzipEncoder.encode(bytes)!);
    }
  }

  /*
  Future<List<int>> _decompressFileFromBase64(String file) async {
    final bytes = base64Decode(file);
    return _isGzFile(bytes) ? _gzipDecoder.decodeBytes(bytes) : bytes;
  }
  */

  Future<List<int>> _decompressFile(Uint8List file) async {
    return _isGzFile(file) ? _gzipDecoder.decodeBytes(file) : file;
  }

  //--- Document Item ---//
  Future<void> _split(DocumentItem documentItem) async {
    if (documentItem.item.status == DocumentStatus.created) {
      await _updateDocumentStatus(documentItem, DocumentStatus.pending);
    }
    if (documentItem.item.status == DocumentStatus.pending) {
      _log.d(documentItem.item.id);
      documentItem.item = (await getDocumentById(documentItem.item.id!))!;
      final chunkSize = _settingService.get(chunkSizeKey).value;
      final chunkOverlap = _settingService.get(chunkOverlapKey).value;
      final url = StringBuffer()
        ..write(_settingService.get(splitApiUrlKey).value)
        ..write('?$chunkSizeQueryString=$chunkSize')
        ..write('&$chunkOverlapQueryString=$chunkOverlap');

      _log.d('url $url');

      await _apiService
          .split(
            _dio,
            url.toString(),
            documentItem,
            _updateDocumentStatus,
            _onProgress,
            _onSplitCompleted,
            _onError,
          )
          .timeout(
            Duration(
              seconds: max(
                (documentItem.item.originFileSize * 0.001).round(),
                900,
              ),
            ),
          );
    }
  }

  Future<void> _updateDocumentStatus(
    DocumentItem documentItem,
    DocumentStatus status,
  ) async {
    _log.d('item.name ${documentItem.item.name}, status $status');
    documentItem.item = (await _documentRepository.updateDocumentStatus(
      documentItem.item.copyWith(
        status: status,
      ),
    ))!;
    _log.d('done!');
    notifyListeners();
  }

  Future<void> _handleError(
    DocumentItem documentItem,
    String? errorMessage,
  ) async {
    _log.e(errorMessage);
    await updateDocumentDoneStatus(
      documentItem,
      DocumentStatus.failed,
      errorMessage,
    );
  }

  void _onProgress(
    DocumentItem documentItem,
    double progress,
  ) {
    documentItem.progress = progress;
    notifyListeners();
  }

  Future<void> _onSplitCompleted(
    DocumentItem documentItem,
    Map<String, dynamic>? responseData,
  ) async {
    _log.d('responseData $responseData');
    final embeddings = await _splitted(documentItem, responseData).timeout(
      Duration(seconds: max((responseData?['items'] as List).length, 600)),
    );
    await _mutex.protect(() async {
      await _indexing(documentItem, embeddings).timeout(
        Duration(seconds: max(embeddings.length, 900)),
      );
    });
  }

  Future<List<Embedding>> _splitted(
    DocumentItem documentItem,
    Map<String, dynamic>? responseData,
  ) async {
    _log.d('1. documentItem.hashCode ${documentItem.hashCode}');
    final documentItems =
        List<Map<String, dynamic>>.from(responseData?['items'] as List);
    if (documentItems.isEmpty) {
      final document = await getDocumentById(documentItem.item.id!);
      documentItems.add({
        'content': await convertByteDataToString(
          document!.byteData!,
        ),
      });
    }

    final now = DateTime.now();
    final fullTableName = '${documentItem.tablePrefix}_${Embedding.tableName}';
    final dimensions = int.parse(
      _settingService.get(embeddingsDimensionsKey).value,
    );
    final emptyEmbedding = List<double>.filled(dimensions, 0);
    final embeddings = List<Embedding>.from(
      documentItems
          .map(
            (item) => Embedding(
              id: '$fullTableName:${Ulid()}',
              content: item['content'] as String,
              embedding: emptyEmbedding,
              metadata: item['metadata'],
            ),
          )
          .toList(),
    );
    final document = documentItem.item.copyWith(
      content: responseData?['content'] != null
          ? responseData!['content'] as String
          : null,
      contentMimeType: responseData?['mime_type'] as String,
      status: DocumentStatus.indexing,
      splitted: now,
    );

    final txnResults = await updateDocumentAndCreateEmbeddings(
      documentItem.tablePrefix,
      document,
      embeddings,
    );
    _log.d('txnResults $txnResults');
    final results = txnResults! as List;
    final documentResultMap = results[0] as Map;
    documentItem.item = Document.fromJson(
      Map<String, dynamic>.from(documentResultMap['result'] as Map),
    );
    final embeddingsResultsMap = results[1] as Map;
    final embeddingsResults = embeddingsResultsMap['result'] as List;
    assert(
      embeddingsResults.length == embeddings.length,
      'Length of the document embeddings result should equals to embeddings',
    );
    notifyListeners();
    return embeddings;
  }

  Future<void> _indexing(
    DocumentItem documentItem,
    List<Embedding> embeddings,
  ) async {
    final chunkedTexts = embeddings
        .map(
          (embedding) => embedding.content,
        )
        .toList();

    final vectors = await _apiService
        .index(
          _dio,
          _settingService.get(embeddingsModelKey).value,
          _settingService.get(embeddingsApiUrlKey).value,
          _settingService.get(embeddingsApiKey).value,
          chunkedTexts,
          batchSize: int.parse(
            _settingService.get(embeddingsApiBatchSizeKey).value,
          ),
          dimensions: int.parse(
            _settingService.get(embeddingsDimensionsKey).value,
          ),
          compressed: bool.parse(
            _settingService.get(embeddingsCompressedKey).value,
          ),
        )
        .timeout(
          Duration(seconds: max(embeddings.length, 900)),
        );

    await _updateEmbeddings(
      documentItem.tablePrefix,
      embeddings,
      vectors,
    );

    await updateDocumentDoneStatus(
      documentItem,
      DocumentStatus.completed,
    );
  }

  // ignore: prefer_void_to_null
  Future<Null> _onError(DocumentItem documentItem, dynamic error) async {
    _log.e(error);
    // Handle the error in here
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        await updateDocumentDoneStatus(documentItem, DocumentStatus.canceled);
      } else {
        await _handleError(documentItem, error.message);
      }
    } else {
      await _handleError(documentItem, error.toString());
    }
  }

  Future<void> updateDocumentDoneStatus(
    DocumentItem documentItem,
    DocumentStatus status, [
    String? errorMessage,
  ]) async {
    final now = DateTime.now();

    documentItem.item = (errorMessage == null
        ? await _documentRepository.updateDocument(
            documentItem.item.copyWith(
              status: status,
              done: now,
            ),
          )
        : await _documentRepository.updateDocument(
            documentItem.item.copyWith(
              status: status,
              errorMessage: errorMessage,
              done: now,
            ),
          ))!;

    notifyListeners();
  }

  Future<void> updateDocumentIndexingStatus(DocumentItem documentItem) async {
    final now = DateTime.now();
    documentItem.item = (await _documentRepository.updateDocument(
      documentItem.item.copyWith(
        status: DocumentStatus.indexing,
        splitted: now,
      ),
    ))!;
    notifyListeners();
  }
}
```

document/lib/src/services/document_embedding_repository.dart
```dart
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_embedding.dart';
import 'package:document/src/services/embedding.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class DocumentEmbeddingRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${DocumentEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema =
        DocumentEmbedding.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<DocumentEmbedding> createDocumentEmbedding(
    String tablePrefix,
    DocumentEmbedding documentEmbedding, [
    Transaction? txn,
  ]) async {
    final documentId = documentEmbedding.documentId;
    final embeddingId = documentEmbedding.embeddingId;

    final sql = '''
RELATE ONLY $documentId->${tablePrefix}_${DocumentEmbedding.tableName}->$embeddingId;''';
    if (txn == null) {
      final result = await _db.query(
        sql,
      );

      final map = result! as Map;
      map['documentId'] = map.remove('in');
      map['embeddingId'] = map.remove('out');
      return DocumentEmbedding.fromJson(
        Map<String, dynamic>.from(map),
      );
    } else {
      txn.query(
        sql,
      );
      return documentEmbedding;
    }
  }

  Future<List<DocumentEmbedding>> createDocumentEmbeddings(
    String tablePrefix,
    List<DocumentEmbedding> documentEmbeddings, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final documentEmbedding in documentEmbeddings) {
      final documentId = documentEmbedding.documentId;
      final embeddingId = documentEmbedding.embeddingId;
      final fullTableName = '${tablePrefix}_${DocumentEmbedding.tableName}';
      sqlBuffer.write('RELATE ONLY $documentId->$fullTableName->$embeddingId;');
    }

    if (txn == null) {
      final results = (await _db.query(sqlBuffer.toString()))! as List;

      return results.map(
        (result) {
          final map = result as Map;
          map['documentId'] = map.remove('in');
          map['embeddingId'] = map.remove('out');
          return DocumentEmbedding.fromJson(
            Map<String, dynamic>.from(map),
          );
        },
      ).toList();
    } else {
      txn.query(sqlBuffer.toString());
      return documentEmbeddings;
    }
  }

  Future<List<Embedding>> getAllEmbeddingsOfDocument(
    String tablePrefix,
    String documentId,
  ) async {
    final documentEmbeddingTableName =
        '${tablePrefix}_${DocumentEmbedding.tableName}';
    final documentTableName = '${tablePrefix}_${Document.tableName}';
    final sql = '''
SELECT ->$documentEmbeddingTableName->${tablePrefix}_${Embedding.tableName}.* 
AS Embedding FROM $documentTableName 
WHERE array::first(array::distinct(->$documentEmbeddingTableName<-$documentTableName)) == $documentId;
''';

    final results = (await _db.query(
      sql,
    ))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final embeddings = result['Embedding'] as List;

    return embeddings
        .map(
          (result) => Embedding.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }
}
```

document/lib/src/app/app.dart
```dart
import 'package:archive/archive.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.dart';
import 'package:document/src/ui/views/document_list/document_list_view.dart';
import 'package:document/src/ui/views/startup/startup_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: DocumentListView),
// @stacked-route
  ],
  dependencies: [
    Factory(classType: Dio),
    LazySingleton<DialogService>(classType: DialogService),
    LazySingleton<DocumentApiService>(classType: DocumentApiService),
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<GZipEncoder>(classType: GZipEncoder),
    LazySingleton<GZipDecoder>(classType: GZipDecoder),
    LazySingleton<DocumentService>(classType: DocumentService),
    LazySingleton<DocumentRepository>(classType: DocumentRepository),
    LazySingleton<EmbeddingRepository>(classType: EmbeddingRepository),
    LazySingleton<DocumentEmbeddingRepository>(
      classType: DocumentEmbeddingRepository,
    ),
    LazySingleton<BatchService>(classType: BatchService),

    LazySingleton<Surreal>(
      classType: SurrealWasmMutex,
      asType: Surreal,
      resolveUsing: SurrealWasmMutex.getInstance,
    ),
    LazySingleton<FlutterSecureStorage>(classType: FlutterSecureStorage),
    LazySingleton<ConnectionSettingRepository>(
      classType: ConnectionSettingRepository,
    ),
    LazySingleton<ConnectionSettingService>(
      classType: ConnectionSettingService,
    ),
// @stacked-service
  ],
  dialogs: [
    StackedDialog(classType: ConnectionDialog),
    StackedDialog(classType: EmbeddingDialog),
// @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
```

document/lib/document.dart
```dart
/// document package
library document;

export 'src/services/batch_service.dart';
export 'src/services/document.dart';
export 'src/services/document_api_service.dart';
export 'src/services/document_embedding.dart';
export 'src/services/document_embedding_repository.dart';
export 'src/services/document_repository.dart';
export 'src/services/document_service.dart';
export 'src/services/embedding.dart';
export 'src/services/embedding_repository.dart';
export 'src/ui/dialogs/embedding/embedding_dialog.dart';
export 'src/ui/dialogs/info_alert/info_alert_dialog.dart';
export 'src/ui/views/document_list/document_list_view.dart';
```