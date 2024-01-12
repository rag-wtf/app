import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_message.dart';
import 'package:chat/src/services/message.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ChatMessageRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${ChatMessage.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = ChatMessage.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<ChatMessage> createChatMessage(
    String tablePrefix,
    ChatMessage chatMessage, [
    Transaction? txn,
  ]) async {
    final chatId = chatMessage.chatId;
    final messageId = chatMessage.messageId;

    final sql = '''
RELATE ONLY $chatId->${tablePrefix}_${ChatMessage.tableName}->$messageId;''';
    if (txn == null) {
      final result = await _db.query(
        sql,
      );

      final map = (result! as List).first as Map;
      map['chatId'] = map.remove('in');
      map['messageId'] = map.remove('out');
      return ChatMessage.fromJson(
        Map<String, dynamic>.from(map),
      );
    } else {
      txn.query(
        sql,
      );
      return chatMessage;
    }
  }

  Future<List<ChatMessage>> createChatMessages(
    String tablePrefix,
    List<ChatMessage> chatMessages, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final chatMessage in chatMessages) {
      final chatId = chatMessage.chatId;
      final messageId = chatMessage.messageId;
      final fullTableName = '${tablePrefix}_${ChatMessage.tableName}';
      sqlBuffer.write('RELATE ONLY $chatId->$fullTableName->$messageId;');
    }

    if (txn == null) {
      final results = (await _db.query(sqlBuffer.toString()))! as List;

      return results.map(
        (result) {
          final map = result as Map;
          map['chatId'] = map.remove('in');
          map['messageId'] = map.remove('out');
          return ChatMessage.fromJson(
            Map<String, dynamic>.from(map),
          );
        },
      ).toList();
    } else {
      txn.query(sqlBuffer.toString());
      return chatMessages;
    }
  }

  Future<List<Message>> getAllMessagesOfChat(
    String tablePrefix,
    String chatId,
  ) async {
    final chatMessageTableName = '${tablePrefix}_${ChatMessage.tableName}';
    final chatTableName = '${tablePrefix}_${Chat.tableName}';
    final messageTableName = '${tablePrefix}_${Message.tableName}';
    final sql = '''
SELECT ->$chatMessageTableName->${tablePrefix}_${Message.tableName}.* 
AS $messageTableName FROM $chatTableName 
WHERE array::first(array::distinct(->$chatMessageTableName<-$chatTableName)) == $chatId;
''';

    final results = (await _db.query(
      sql,
    ))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final messages = result[messageTableName] as List;

    return messages
        .map(
          (result) => Message.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }
}
