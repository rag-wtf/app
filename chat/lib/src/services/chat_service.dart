import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_message.dart';
import 'package:chat/src/services/conversation_message_repository.dart';
import 'package:chat/src/services/conversation_repository.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ChatService {
  final _db = locator<Surreal>();
  final _conversationRepository = locator<ConversationRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _conversationMessageRepository =
      locator<ConversationMessageRepository>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Conversation.tableName}') &&
        tables.containsKey('${tablePrefix}_${Message.tableName}') &&
        tables.containsKey('${tablePrefix}_${ConversationMessage.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await _db.transaction(
        (txn) async {
          await _conversationRepository.createSchema(tablePrefix, txn);
          await _messageRepository.createSchema(tablePrefix, txn);
          await _conversationMessageRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await _conversationRepository.createSchema(tablePrefix, txn);
      await _messageRepository.createSchema(tablePrefix, txn);
      await _conversationMessageRepository.createSchema(tablePrefix, txn);
    }
  }

  Future<Object?> createConversationAndMessage(
    String tablePrefix,
    Conversation conversation,
    Message message, [
    Transaction? txn,
  ]) async {
    final conversationMessage = ConversationMessage(
      conversationId: conversation.id!,
      messageId: message.id!,
    );
    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _conversationRepository.createConversation(
            tablePrefix,
            conversation,
            txn,
          );

          await _messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
          await _conversationMessageRepository.createConversationMessage(
            tablePrefix,
            conversationMessage,
            txn,
          );
        },
      );
    } else {
      await _conversationRepository.createConversation(
        tablePrefix,
        conversation,
        txn,
      );

      await _messageRepository.createMessage(
        tablePrefix,
        message,
        txn,
      );
      await _conversationMessageRepository.createConversationMessage(
        tablePrefix,
        conversationMessage,
        txn,
      );
      return null;
    }
  }

  Future<Object?> createMessage(
    String tablePrefix,
    Conversation conversation,
    Message message, [
    Transaction? txn,
  ]) async {
    final conversationMessage = ConversationMessage(
      conversationId: conversation.id!,
      messageId: message.id!,
    );
    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
          await _conversationMessageRepository.createConversationMessage(
            tablePrefix,
            conversationMessage,
            txn,
          );
        },
      );
    } else {
      await _messageRepository.createMessage(
        tablePrefix,
        message,
        txn,
      );
      await _conversationMessageRepository.createConversationMessage(
        tablePrefix,
        conversationMessage,
        txn,
      );
      return null;
    }
  }

  Future<ConversationList> getConversationList(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final items = await _conversationRepository.getAllConversations(
      tablePrefix,
      page: page,
      pageSize: pageSize,
      ascendingOrder: ascendingOrder,
    );
    final total = await _conversationRepository.getTotal(tablePrefix);
    return ConversationList(items, total);
  }
}
