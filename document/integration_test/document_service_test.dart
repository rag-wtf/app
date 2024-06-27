import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final documentService = locator<DocumentService>();
  const tablePrefix = 'doc_service';

  setUpAll(() async {
    await db.connect(surrealEndpoint);
    await db.use(namespace: surrealNamespace, database: surrealDatabase);
    await db.signin({'username': surrealUsername, 'password': surrealPassword});
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
        await documentService.createSchema(tablePrefix);
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
}
