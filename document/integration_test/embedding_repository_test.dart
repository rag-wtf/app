import 'dart:convert';

import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<EmbeddingRepository>();

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

  group('createEmbedding', () {
    test('should create embedding', () async {
      // Arrange
      final embedding = Embedding(
        content: 'apple',
        embedding: testData['apple'],
        metadata: {'id': 'customId1'},
      );

      // Act
      final result =
          await repository.createEmbedding(defaultTablePrefix, embedding);

      // Assert
      expect(result.id, isNotNull);

      // Clean up
      await db.delete('${defaultTablePrefix}_${Embedding.tableName}');
    });

    test('should have validation errors', () async {
      // Arrange
      final embedding = Embedding(
        content: 'apple',
        embedding: testData['apple'],
        metadata: {'id': 'customId1'},
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
    });
  });

  group('createEmbeddings', () {
    test('should create embeddings', () async {
      // Arrange
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: testData['apple'],
          metadata: {'id': 'customId1'},
        ),
        Embedding(
          content: 'ten',
          embedding: testData['ten'],
          metadata: {'id': 'customId2'},
        ),
        Embedding(
          content: 'twenty',
          embedding: testData['twenty'],
          metadata: {'id': 'customId3'},
        ),
        Embedding(
          content: 'two',
          embedding: testData['two'],
          metadata: {'id': 'customId4'},
        ),
        Embedding(
          content: 'banana',
          embedding: testData['banana'],
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

    test('should have validation errors', () async {
      // Arrange
      final embedding = Embedding(
        content: '',
        embedding: testData['apple'],
        metadata: {'id': 'customId1'},
      );

      // Act
      final result = await repository.createEmbeddings(
        defaultTablePrefix,
        [embedding],
      );

      // Assert
      expect(
        result.first.errors?.first.message.startsWith(
          'minLength violated',
        ),
        isTrue,
      );
    });
  });

  group('getAllEmbeddings', () {
    test('should return a list of embeddings', () async {
      // Arrange
      final embeddings = [
        Embedding(
          content: 'apple',
          embedding: testData['apple'],
          metadata: {'id': 'customId1'},
        ).toJson(),
        Embedding(
          content: 'ten',
          embedding: testData['ten'],
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
        embedding: testData['ten'],
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

  group('updateEmbedding', () {
    test('should update embedding', () async {
      // Arrange
      final embedding = Embedding(
        content: 'ten',
        embedding: testData['ten'],
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
        embedding: testData['ten'],
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
        embedding: testData['ten'],
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
          embedding: testData['apple'],
          metadata: {'id': 'customId1'},
        ),
        Embedding(
          content: 'ten',
          embedding: testData['ten'],
          metadata: {'id': 'customId2'},
        ),
        Embedding(
          content: 'twenty',
          embedding: testData['twenty'],
          metadata: {'id': 'customId3'},
        ),
        Embedding(
          content: 'two',
          embedding: testData['two'],
          metadata: {'id': 'customId4'},
        ),
        Embedding(
          content: 'banana',
          embedding: testData['banana'],
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
      );
      final result2 = await repository.similaritySearch(
        defaultTablePrefix,
        listAllFruits,
        k,
      );

      // Assert
      expect(result1, hasLength(k));
      expect(
        result1.map((e) => e.content).toList(),
        equals(
          ['ten', 'twenty', 'apple'],
        ),
      );

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
