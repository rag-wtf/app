import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_message.dart';
import 'package:chat/src/services/message.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ConversationMessageRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables
        .containsKey('${tablePrefix}_${ConversationMessage.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema =
        ConversationMessage.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<ConversationMessage> createConversationMessage(
    String tablePrefix,
    ConversationMessage conversationMessage, [
    Transaction? txn,
  ]) async {
    final conversationId = conversationMessage.conversationId;
    final messageId = conversationMessage.messageId;

    final sql = '''
RELATE ONLY $conversationId->${tablePrefix}_${ConversationMessage.tableName}->$messageId;''';
    if (txn == null) {
      final result = await _db.query(
        sql,
      );

      final map = (result! as List).first as Map;
      map['conversationId'] = map.remove('in');
      map['messageId'] = map.remove('out');
      return ConversationMessage.fromJson(
        Map<String, dynamic>.from(map),
      );
    } else {
      txn.query(
        sql,
      );
      return conversationMessage;
    }
  }

  Future<List<ConversationMessage>> createConversationMessages(
    String tablePrefix,
    List<ConversationMessage> conversationMessages, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final conversationMessage in conversationMessages) {
      final conversationId = conversationMessage.conversationId;
      final messageId = conversationMessage.messageId;
      final fullTableName = '${tablePrefix}_${ConversationMessage.tableName}';
      sqlBuffer
          .write('RELATE ONLY $conversationId->$fullTableName->$messageId;');
    }

    if (txn == null) {
      final results = (await _db.query(sqlBuffer.toString()))! as List;

      return results.map(
        (result) {
          final map = result as Map;
          map['conversationId'] = map.remove('in');
          map['messageId'] = map.remove('out');
          return ConversationMessage.fromJson(
            Map<String, dynamic>.from(map),
          );
        },
      ).toList();
    } else {
      txn.query(sqlBuffer.toString());
      return conversationMessages;
    }
  }

  Future<List<Message>> getAllMessagesOfConversation(
    String tablePrefix,
    String conversationId,
  ) async {
    final conversationMessageTableName =
        '${tablePrefix}_${ConversationMessage.tableName}';
    final conversationTableName = '${tablePrefix}_${Conversation.tableName}';
    final messageTableName = '${tablePrefix}_${Message.tableName}';
    final sql = '''
SELECT ->$conversationMessageTableName->${tablePrefix}_${Message.tableName}.* 
AS $messageTableName FROM $conversationTableName 
WHERE array::first(array::distinct(->$conversationMessageTableName<-$conversationTableName)) == $conversationId;
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
