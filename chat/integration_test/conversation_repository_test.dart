import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<ConversationRepository>();

  setUpAll(() async {});

  tearDown(() async {
    await repository.deleteAllConversations(defaultTablePrefix);
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

  group('createConversation', () {
    test('should create conversation', () async {
      // Arrange
      final conversation = Conversation(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      // Act
      final result =
          await repository.createConversation(defaultTablePrefix, conversation);

      // Assert
      expect(result.name, equals('name1'));
    });
  });
  group('getAllConversations', () {
    test('should return a list of conversations', () async {
      // Arrange
      final conversations = [
        Conversation(
          name: 'name1',
          created: DateTime.now(),
          updated: DateTime.now(),
        ).toJson(),
        Conversation(
          name: 'name2',
          created: DateTime.now(),
          updated: DateTime.now(),
        ).toJson(),
      ];
      await db.delete('${defaultTablePrefix}_${Conversation.tableName}');
      await db.query(
        'INSERT INTO ${defaultTablePrefix}_${Conversation.tableName} ${jsonEncode(conversations)}',
      );

      // Act
      final result = await repository.getAllConversations(defaultTablePrefix);

      // Assert
      expect(result, hasLength(conversations.length));
    });
  });

  group('getConversationById', () {
    test('should return a conversation by id', () async {
      // Arrange
      final metadata = {'field': 'value'};
      final conversation = Conversation(
        name: 'name1',
        metadata: metadata,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final result =
          await repository.createConversation(defaultTablePrefix, conversation);
      final id = result.id!;

      // Act
      final getConversationById = await repository.getConversationById(id);

      // Assert
      expect(getConversationById?.id, equals(id));
      expect(getConversationById?.metadata, equals(metadata));
    });

    test('should not found', () async {
      // Arrange
      const id = 'Conversation:1';

      // Act & Assert
      expect(await repository.getConversationById(id), isNull);
    });
  });

  group('updateConversation', () {
    test('should update conversation', () async {
      // Arrange
      final conversation = Conversation(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final created =
          await repository.createConversation(defaultTablePrefix, conversation);

      // Act
      const name1 = 'name one';
      final updated =
          await repository.updateConversation(created.copyWith(name: name1));

      // Assert
      expect(updated?.name, equals(name1));
    });

    test('should be null when the update conversation is not found', () async {
      // Arrange
      final conversation = Conversation(
        id: '${defaultTablePrefix}_${Conversation.tableName}:1',
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      // Act & Assert
      expect(await repository.updateConversation(conversation), isNull);
    });
  });

  group('deleteConversation', () {
    test('should delete conversation', () async {
      // Arrange
      final conversation = Conversation(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final created =
          await repository.createConversation(defaultTablePrefix, conversation);

      // Act
      final result = await repository.deleteConversation(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete conversation is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Conversation.tableName}:1';

      // Act & Assert
      expect(await repository.deleteConversation(id), isNull);
    });
  });
}
