import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final chatRepository = locator<ChatRepository>();
  final messageRepository = locator<MessageRepository>();
  final chatMessageRepository = locator<ChatMessageRepository>();
  const tablePrefix = 'conv_message';

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
      id: '${tablePrefix}_${Chat.tableName}:${Ulid()}',
      name: 'chat 1',
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
    final txnResults = await db.transaction(
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
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${ChatMessage.tableName}'),
      hasLength(1),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Chat.tableName}');
    await db.delete('${tablePrefix}_${Message.tableName}');
  });

  test('should retrieve messages of given chat Id', () async {
    // Arrange
    final chat1 = Chat(
      id: '${tablePrefix}_${Chat.tableName}:${Ulid()}',
      name: 'chat 1',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    final chat2 = Chat(
      id: '${tablePrefix}_${Chat.tableName}:${Ulid()}',
      name: 'chat 2',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    final messages1 = [
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: 'user:${Ulid()}',
        text: 'user message 1 of 1',
        type: MessageType.text,
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: 'user:${Ulid()}',
        text: 'user message 2 of 1',
        type: MessageType.text,
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
    ];
    final messages2 = [
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: 'user:${Ulid()}',
        text: 'user message 1 of 2',
        type: MessageType.text,
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: 'user:${Ulid()}',
        text: 'user message 2 of 2',
        type: MessageType.text,
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
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
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await chatMessageRepository.getAllMessagesOfChat(
        tablePrefix,
        chat2.id!,
      ),
      hasLength(chatMessages2.length),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Chat.tableName}');
    await db.delete('${tablePrefix}_${Message.tableName}');
  });
}
