import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<ChatRepository>();

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
    await repository.deleteAllChats(defaultTablePrefix);
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

  group('createChat', () {
    test('should create chat', () async {
      // Arrange
      const chat = Chat(
        name: 'name1',
      );

      // Act
      final result = await repository.createChat(defaultTablePrefix, chat);

      // Assert
      expect(result.name, equals('name1'));
      expect(result.vote, equals(0));
      expect(result.share, equals(0));
      expect(result.created, isNotNull);
      expect(result.updated, isNotNull);
    });
  });
  group('getAllChats', () {
    test('should return a list of chats', () async {
      // Arrange
      final chats = [
        const Chat(
          name: 'name1',
        ).toJson(),
        const Chat(
          name: 'name2',
        ).toJson(),
      ];
      await db.delete('${defaultTablePrefix}_${Chat.tableName}');
      await db.query(
        '''
INSERT INTO ${defaultTablePrefix}_${Chat.tableName} ${jsonEncode(chats)}''',
      );

      // Act
      final result = await repository.getAllChats(defaultTablePrefix);

      // Assert
      expect(result, hasLength(chats.length));
    });
  });

  group('getChatById', () {
    test('should return a chat by id', () async {
      // Arrange
      final metadata = {'field': 'value'};
      final chat = Chat(
        name: 'name1',
        metadata: metadata,
      );
      final result = await repository.createChat(defaultTablePrefix, chat);
      final id = result.id!;

      // Act
      final getChatById = await repository.getChatById(id);

      // Assert
      expect(getChatById?.id, equals(id));
      expect(getChatById?.metadata, equals(metadata));
    });

    test('should not found', () async {
      // Arrange
      const id = 'Chat:1';

      // Act & Assert
      expect(await repository.getChatById(id), isNull);
    });
  });

  group('updateChat', () {
    test('should update chat', () async {
      // Arrange
      const chat = Chat(
        name: 'name1',
      );
      final created = await repository.createChat(defaultTablePrefix, chat);

      // Act
      const name1 = 'name one';
      await repository.updateChat(
        defaultTablePrefix,
        created.copyWith(name: name1),
      );
      final updated = await repository.getChatById(created.id!);

      // Assert
      expect(updated, isNotNull);
      expect(updated?.name, equals(name1));
      expect(updated!.updated!.isAfter(updated.created!), isTrue);
    });

    test('should be null when the update chat is not found', () async {
      // Arrange
      const chat = Chat(
        id: '${defaultTablePrefix}_${Chat.tableName}:1',
        name: 'name1',
      );
      // Act & Assert
      expect(await repository.updateChat(defaultTablePrefix, chat), isNull);
    });
  });

  group('deleteChat', () {
    test('should delete chat', () async {
      // Arrange
      const chat = Chat(
        name: 'name1',
      );
      final created = await repository.createChat(defaultTablePrefix, chat);

      // Act
      final result = await repository.deleteChat(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete chat is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Chat.tableName}:1';

      // Act & Assert
      expect(await repository.deleteChat(id), isNull);
    });
  });
}
