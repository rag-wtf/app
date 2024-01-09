import 'dart:convert';

import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final chatService = locator<ChatService>();
  const tablePrefix = 'chat_service';

  tearDown(() async {
    await db.delete('${tablePrefix}_${Conversation.tableName}');
    await db.delete('${tablePrefix}_${Message.tableName}');
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await chatService.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      if (!await chatService.isSchemaCreated(tablePrefix)) {
        await chatService.createSchema(tablePrefix);
      }

      // Assert
      expect(await chatService.isSchemaCreated(tablePrefix), isTrue);
    });
  });

  test('should create conversation and message', () async {
    // Arrange
    final conversation = Conversation(
      id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
      name: 'conversation 1',
      created: DateTime.now(),
      updated: DateTime.now(),
    );
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      authorId: 'user:${Ulid()}',
      text: 'user message 1',
      type: MessageType.text,
      metadata: {'id': 'customId1'},
      created: DateTime.now(),
      updated: DateTime.now(),
    );
    // Act
    final txnResults = await chatService.createConversationAndMessage(
      tablePrefix,
      conversation,
      message,
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${ConversationMessage.tableName}'),
      hasLength(1),
    );
  });

  test('get conversation list with total', () async {
    // Arrange
    final conversations = List.generate(
      5,
      (index) => Conversation(
        id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
        name: 'conversation$index',
        created: DateTime.now(),
        updated: DateTime.now().add(Duration(seconds: index)),
      ).toJson(),
    );
    final sql = '''
INSERT INTO ${tablePrefix}_${Conversation.tableName} ${jsonEncode(conversations)}''';
    await db.query(sql);

    // Act
    const pageSize = 2;
    final page1 = await chatService.getConversationList(
      tablePrefix,
      page: 0,
      pageSize: pageSize,
    );
    final page2 = await chatService.getConversationList(
      tablePrefix,
      page: 1,
      pageSize: pageSize,
    );
    final page3 = await chatService.getConversationList(
      tablePrefix,
      page: 2,
      pageSize: pageSize,
    );

    // Assert
    expect(page1.items, hasLength(pageSize));
    expect(page1.total, equals(conversations.length));
    print('page1 ${page1.items.map((e) => e.name)}');
    expect(page1.items[0].name, equals('conversation4'));
    expect(page1.items[1].name, equals('conversation3'));

    expect(page2.items, hasLength(pageSize));
    expect(page2.total, equals(conversations.length));
    expect(page2.items[0].name, equals('conversation2'));
    expect(page2.items[1].name, equals('conversation1'));

    expect(page3.items, hasLength(1));
    expect(page3.total, equals(conversations.length));
    expect(page3.items[0].name, equals('conversation0'));
  });
}
