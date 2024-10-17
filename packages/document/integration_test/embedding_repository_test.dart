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
        defaultTablePrefix,
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
      expect(
        await repository.updateEmbedding(defaultTablePrefix, embedding),
        isNull,
      );
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
