import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_message.dart';
import 'package:chat/src/services/message.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class ChatMessageRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('ChatMessageRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
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

      final map = result! as Map;
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

  Future<MessageList> getAllMessagesOfChat(
    String tablePrefix,
    String chatId, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final chatMessageTableName = '${tablePrefix}_${ChatMessage.tableName}';
    final sql = '''
LET \$messages = (SELECT out AS id FROM $chatMessageTableName
WHERE in = '$chatId');
SELECT count() FROM \$messages.*.id GROUP ALL;
SELECT * FROM \$messages.*.id
ORDER BY updated ${ascendingOrder ? 'ASC' : 'DESC'}
${page == null ? ';' : ' LIMIT $pageSize START ${page * pageSize};'}
''';

    final results = (await _db.query(
      sql,
    ))! as List;
    _log.d(results);
    final totalList = results[1] as List;
    final total =
        totalList.isNotEmpty ? (totalList.first as Map)['count'] as int : 0;
    final messages = results.last as List;

    return MessageList(
      messages
          .map(
            (result) => Message.fromJson(
              Map<String, dynamic>.from(
                result as Map,
              ),
            ),
          )
          .toList(),
      total,
    );
  }
}
