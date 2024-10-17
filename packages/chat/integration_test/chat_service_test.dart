import 'dart:convert';
import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final chatService = locator<ChatService>();
  const tablePrefix = 'chat_service';

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
    await db.delete('${tablePrefix}_${Chat.tableName}');
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

  test('should create chat and message', () async {
    // Arrange
    final chat = Chat(
      id: Ulid().toString(),
      name: 'chat 1',
    );
    final message = Message(
      id: Ulid().toString(),
      authorId: '$userIdPrefix${Ulid()}',
      role: Role.user,
      text: 'user message 1',
      type: MessageType.text,
      metadata: {'id': 'customId1'},
    );
    // Act
    final txnResults = await chatService.createChatAndMessage(
      tablePrefix,
      chat,
      message,
    );

    // Assert
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${ChatMessage.tableName}'),
      isNotNull,
    );
  });

  test('get chat list with total', () async {
    // Arrange
    final chats = List.generate(
      5,
      (index) => Chat(
        id: Ulid().toString(),
        name: 'chat$index',
        updated: DateTime.now().add(Duration(seconds: index)),
      ).toJson(),
    );
    final sql = '''
INSERT INTO ${tablePrefix}_${Chat.tableName} ${jsonEncode(chats)}''';
    await db.query(sql);

    // Act
    const pageSize = 2;
    final page1 = await chatService.getChatList(
      tablePrefix,
      page: 0,
      pageSize: pageSize,
    );
    final page2 = await chatService.getChatList(
      tablePrefix,
      page: 1,
      pageSize: pageSize,
    );
    final page3 = await chatService.getChatList(
      tablePrefix,
      page: 2,
      pageSize: pageSize,
    );

    // Assert
    expect(page1.items, hasLength(pageSize));
    expect(page1.total, equals(chats.length));
    expect(page1.items[0].name, equals('chat4'));
    expect(page1.items[1].name, equals('chat3'));

    expect(page2.items, hasLength(pageSize));
    expect(page2.total, equals(chats.length));
    expect(page2.items[0].name, equals('chat2'));
    expect(page2.items[1].name, equals('chat1'));

    expect(page3.items, hasLength(1));
    expect(page3.total, equals(chats.length));
    expect(page3.items[0].name, equals('chat0'));
  });
}
