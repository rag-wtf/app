import 'dart:convert';

import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<MessageRepository>();

  tearDown(() async {
    await repository.deleteAllMessages(defaultTablePrefix);
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

  group('createMessage', () {
    test('should create message', () async {
      // Arrange
      final metadata = {'id': 'customId1'};
      final message = Message(
        authorId: defaultAgentId,
        role: Role.agent,
        text: 'agent message 1',
        type: MessageType.text,
        metadata: metadata,
      );

      // Act
      final result =
          await repository.createMessage(defaultTablePrefix, message);

      // Assert
      expect(result.id, isNotNull);
      expect(result.authorId, equals(defaultAgentId));
      expect(result.metadata, equals(metadata));

      // Clean up
      await db.delete('${defaultTablePrefix}_${Message.tableName}');
    });
  });

  group('getAllMessages', () {
    test('should return a list of messages', () async {
      // Arrange
      final userId = '$userIdPrefix${Ulid()}';
      final messages = List.generate(
        5,
        (index) => Message(
          authorId: userId,
          role: Role.user,
          text: 'user message $index',
          type: MessageType.text,
          metadata: {'id': 'customId$index'},
        ).toJson(),
      );
      const fullMessageTableName = '${defaultTablePrefix}_${Message.tableName}';
      await db.delete(fullMessageTableName);
      await db.query(
        'INSERT INTO $fullMessageTableName ${jsonEncode(messages)}',
      );

      // Act
      final result = await repository.getAllMessages(defaultTablePrefix);

      // Assert
      expect(result, hasLength(messages.length));
      expect(result.first.authorId, equals(userId));
    });
  });

  group('getMessageById', () {
    test('should return a message by id', () async {
      // Arrange
      final userId = '$userIdPrefix${Ulid()}';
      final message = Message(
        authorId: userId,
        role: Role.user,
        text: 'user message 1',
        type: MessageType.text,
        metadata: {'id': 'customId1'},
      );
      final result =
          await repository.createMessage(defaultTablePrefix, message);
      final id = result.id!;

      // Act
      final getMessageById = await repository.getMessageById(id);

      // Assert
      expect(getMessageById?.id, equals(id));
    });

    test('should not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Message.tableName}:1';

      // Act & Assert
      expect(await repository.getMessageById(id), isNull);
    });
  });

  group('updateMessage', () {
    test('should update message', () async {
      // Arrange
      final message = Message(
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 1',
        type: MessageType.text,
        metadata: {'id': 'customId1'},
      );
      final created =
          await repository.createMessage(defaultTablePrefix, message);

      // Act
      const remark = 'remark1';
      final updated =
          await repository.updateMessage(created.copyWith(text: remark));

      // Assert
      expect(updated?.text, equals(remark));
    });

    test('should be null when the update message is not found', () async {
      // Arrange
      final message = Message(
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        id: '${Message.tableName}:1',
        text: 'user message 1',
        type: MessageType.text,
        metadata: {'id': 'customId1'},
      );
      // Act & Assert
      expect(await repository.updateMessage(message), isNull);
    });
  });

  group('deleteMessage', () {
    test('should delete message', () async {
      // Arrange
      final message = Message(
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 1',
        type: MessageType.text,
        metadata: {'id': 'customId1'},
      );
      final created =
          await repository.createMessage(defaultTablePrefix, message);

      // Act
      final result = await repository.deleteMessage(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete message is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Message.tableName}:1';

      // Act & Assert
      expect(await repository.deleteMessage(id), isNull);
    });
  });
}
