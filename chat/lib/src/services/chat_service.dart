import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_message.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ChatService {
  final _db = locator<Surreal>();
  final _chatRepository = locator<ChatRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _chatMessageRepository = locator<ChatMessageRepository>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Chat.tableName}') &&
        tables.containsKey('${tablePrefix}_${Message.tableName}') &&
        tables.containsKey('${tablePrefix}_${ChatMessage.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await _db.transaction(
        (txn) async {
          await _chatRepository.createSchema(tablePrefix, txn);
          await _messageRepository.createSchema(tablePrefix, txn);
          await _chatMessageRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await _chatRepository.createSchema(tablePrefix, txn);
      await _messageRepository.createSchema(tablePrefix, txn);
      await _chatMessageRepository.createSchema(tablePrefix, txn);
    }
  }

  Future<Object?> createChatAndMessage(
    String tablePrefix,
    Chat chat,
    Message message, [
    Transaction? txn,
  ]) async {
    final chatMessage = ChatMessage(
      chatId: chat.id!,
      messageId: message.id!,
    );
    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _chatRepository.createChat(
            tablePrefix,
            chat,
            txn,
          );

          await _messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
          await _chatMessageRepository.createChatMessage(
            tablePrefix,
            chatMessage,
            txn,
          );
        },
      );
    } else {
      await _chatRepository.createChat(
        tablePrefix,
        chat,
        txn,
      );

      await _messageRepository.createMessage(
        tablePrefix,
        message,
        txn,
      );
      await _chatMessageRepository.createChatMessage(
        tablePrefix,
        chatMessage,
        txn,
      );
      return null;
    }
  }

  Future<Object?> createMessage(
    String tablePrefix,
    Chat chat,
    Message message, [
    Transaction? txn,
  ]) async {
    final chatMessage = ChatMessage(
      chatId: chat.id!,
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
          await _chatMessageRepository.createChatMessage(
            tablePrefix,
            chatMessage,
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
      await _chatMessageRepository.createChatMessage(
        tablePrefix,
        chatMessage,
        txn,
      );
      return null;
    }
  }

  Future<ChatList> getChatList(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final items = await _chatRepository.getAllChats(
      tablePrefix,
      page: page,
      pageSize: pageSize,
      ascendingOrder: ascendingOrder,
    );
    final total = await _chatRepository.getTotal(tablePrefix);
    return ChatList(items, total);
  }
}
