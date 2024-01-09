import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final conversationRepository = locator<ConversationRepository>();
  final messageRepository = locator<MessageRepository>();
  final conversationMessageRepository =
      locator<ConversationMessageRepository>();
  const tablePrefix = 'doc_emb';

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await conversationRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await conversationMessageRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        (txn) async {
          if (!await conversationRepository.isSchemaCreated(tablePrefix)) {
            await conversationRepository.createSchema(tablePrefix, txn);
          }
          if (!await messageRepository.isSchemaCreated(tablePrefix)) {
            await messageRepository.createSchema(tablePrefix, txn);
          }
          if (!await conversationMessageRepository
              .isSchemaCreated(tablePrefix)) {
            await conversationMessageRepository.createSchema(
              tablePrefix,
              txn,
            );
          }
        },
      );

      // Assert
      expect(
        await conversationRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await conversationMessageRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
    });
  });

  test('should create conversation message', () async {
    // Arrange
    final conversation = Conversation(
      id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
      name: 'conversation 1',
      created: DateTime.now(),
      updated: DateTime.now(),
    );
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      userMessage: 'user message 1',
      botMessage: 'bot message 1',
      metadata: {'id': 'customId1'},
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await conversationRepository.createConversation(
          tablePrefix,
          conversation,
          txn,
        );
        await messageRepository.createMessage(
          tablePrefix,
          message,
          txn,
        );
        await conversationMessageRepository.createConversationMessage(
          tablePrefix,
          ConversationMessage(
            conversationId: conversation.id!,
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
      await db.select('${tablePrefix}_${ConversationMessage.tableName}'),
      hasLength(1),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Conversation.tableName}');
    await db.delete('${tablePrefix}_${Message.tableName}');
  });

  test('should retrieve messages of given conversation Id', () async {
    // Arrange
    final conversation1 = Conversation(
      id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
      name: 'conversation 1',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    final conversation2 = Conversation(
      id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
      name: 'conversation 2',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    final messages1 = [
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        userMessage: 'user message 1 of 1',
        botMessage: 'bot message 1 of 1',
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        userMessage: 'user message 2 of 1',
        botMessage: 'bot message 2 of 1',
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
    ];
    final messages2 = [
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        userMessage: 'user message 1 of 2',
        botMessage: 'bot message 1 of 2',
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        userMessage: 'user message 2 of 2',
        botMessage: 'bot message 2 of 2',
        metadata: {'id': 'customId'},
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
    ];

    final conversationMessages1 = <ConversationMessage>[];
    for (final message in messages1) {
      conversationMessages1.add(
        ConversationMessage(
          conversationId: conversation1.id!,
          messageId: message.id!,
        ),
      );
    }

    final conversationMessages2 = <ConversationMessage>[];
    for (final message in messages2) {
      conversationMessages2.add(
        ConversationMessage(
          conversationId: conversation2.id!,
          messageId: message.id!,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await conversationRepository.createConversation(
          tablePrefix,
          conversation1,
          txn,
        );
        await conversationRepository.createConversation(
          tablePrefix,
          conversation2,
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
        await conversationMessageRepository.createConversationMessages(
          tablePrefix,
          conversationMessages1,
          txn,
        );
        await conversationMessageRepository.createConversationMessages(
          tablePrefix,
          conversationMessages2,
          txn,
        );
      },
    );

    // Assert
    final results = List<List<dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await conversationMessageRepository.getAllMessagesOfConversation(
        tablePrefix,
        conversation2.id!,
      ),
      hasLength(conversationMessages2.length),
    );

    // Clean up
    await db.delete('${tablePrefix}_${Conversation.tableName}');
    await db.delete('${tablePrefix}_${Message.tableName}');
  });
}
