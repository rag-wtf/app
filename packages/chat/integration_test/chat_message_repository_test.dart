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
  final chatRepository = locator<ChatRepository>();
  final messageRepository = locator<MessageRepository>();
  final chatMessageRepository = locator<ChatMessageRepository>();
  const tablePrefix = 'conv_message';

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
    await chatRepository.deleteAllChats(tablePrefix);
    await messageRepository.deleteAllMessages(tablePrefix);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await chatRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await chatMessageRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        showSql: true,
        (txn) async {
          if (!await chatRepository.isSchemaCreated(tablePrefix)) {
            await chatRepository.createSchema(tablePrefix, txn);
          }
          if (!await messageRepository.isSchemaCreated(tablePrefix)) {
            await messageRepository.createSchema(tablePrefix, txn);
          }
          if (!await chatMessageRepository.isSchemaCreated(tablePrefix)) {
            await chatMessageRepository.createSchema(
              tablePrefix,
              txn,
            );
          }
        },
      );

      // Assert
      expect(
        await chatRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await chatMessageRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
    });
  });

  test('should create chat message', () async {
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
    final txnResults = await db.transaction(
      showSql: true,
      (txn) async {
        await chatRepository.createChat(
          tablePrefix,
          chat,
          txn,
        );
        await messageRepository.createMessage(
          tablePrefix,
          message,
          txn,
        );
        await chatMessageRepository.createChatMessage(
          tablePrefix,
          ChatMessage(
            chatId: chat.id!,
            messageId: message.id!,
          ),
          txn,
        );
      },
    );

    // Assert
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${ChatMessage.tableName}'),
      isNotNull,
    );
  });

  test('should retrieve messages of given chat Id', () async {
    // Arrange
    final chat1 = Chat(
      id: Ulid().toString(),
      name: 'chat 1',
    );

    final chat2 = Chat(
      id: Ulid().toString(),
      name: 'chat 2',
    );

    final messages1 = [
      Message(
        id: Ulid().toString(),
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 1 of 1',
        type: MessageType.text,
        metadata: {'id': 'customId'},
      ),
      Message(
        id: Ulid().toString(),
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 2 of 1',
        type: MessageType.text,
        metadata: {'id': 'customId'},
      ),
    ];
    final messages2 = [
      Message(
        id: Ulid().toString(),
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 1 of 2',
        type: MessageType.text,
        metadata: {'id': 'customId'},
      ),
      Message(
        id: Ulid().toString(),
        authorId: '$userIdPrefix${Ulid()}',
        role: Role.user,
        text: 'user message 2 of 2',
        type: MessageType.text,
        metadata: {'id': 'customId'},
      ),
    ];

    final chatMessages1 = <ChatMessage>[];
    for (final message in messages1) {
      chatMessages1.add(
        ChatMessage(
          chatId: chat1.id!,
          messageId: message.id!,
        ),
      );
    }

    final chatMessages2 = <ChatMessage>[];
    for (final message in messages2) {
      chatMessages2.add(
        ChatMessage(
          chatId: chat2.id!,
          messageId: message.id!,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await chatRepository.createChat(
          tablePrefix,
          chat1,
          txn,
        );
        await chatRepository.createChat(
          tablePrefix,
          chat2,
          txn,
        );
        for (final message in messages1) {
          await messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
        }
        for (final message in messages2) {
          await messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
        }
        await chatMessageRepository.createChatMessages(
          tablePrefix,
          chatMessages1,
          txn,
        );
        await chatMessageRepository.createChatMessages(
          tablePrefix,
          chatMessages2,
          txn,
        );
      },
    );

    // Assert
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    final messageList = await chatMessageRepository.getAllMessagesOfChat(
      tablePrefix,
      chat2.id!,
    );
    expect(
      messageList.items,
      hasLength(chatMessages2.length),
    );
  });
}
