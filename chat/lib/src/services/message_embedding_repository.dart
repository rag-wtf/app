import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/services/message_embedding.dart';
import 'package:document/document.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class MessageEmbeddingRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${MessageEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema =
        MessageEmbedding.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<MessageEmbedding> createMessageEmbedding(
    String tablePrefix,
    MessageEmbedding messageEmbedding, [
    Transaction? txn,
  ]) async {
    final messageId = messageEmbedding.messageId;
    final embeddingId = messageEmbedding.embeddingId;

    final sql = '''
RELATE ONLY $messageId->${tablePrefix}_${MessageEmbedding.tableName}->$embeddingId
SET searchType = '${messageEmbedding.searchType}', score = ${messageEmbedding.score};
''';
    if (txn == null) {
      final result = await _db.query(
        sql,
      );

      final map = result! as Map;
      map['messageId'] = map.remove('in');
      map['embeddingId'] = map.remove('out');
      return MessageEmbedding.fromJson(
        Map<String, dynamic>.from(map),
      );
    } else {
      txn.query(
        sql,
      );
      return messageEmbedding;
    }
  }

  Future<List<MessageEmbedding>> createMessageEmbeddings(
    String tablePrefix,
    List<MessageEmbedding> messageEmbeddings, [
    Transaction? txn,
  ]) async {
    final sqlBuffer = StringBuffer();
    for (final messageEmbedding in messageEmbeddings) {
      final messageId = messageEmbedding.messageId;
      final embeddingId = messageEmbedding.embeddingId;
      final fullTableName = '${tablePrefix}_${MessageEmbedding.tableName}';
      sqlBuffer.write('''
RELATE ONLY $messageId->$fullTableName->$embeddingId
SET searchType = '${messageEmbedding.searchType}', score = ${messageEmbedding.score};
''');
    }

    if (txn == null) {
      final results = (await _db.query(sqlBuffer.toString()))! as List;

      return results.map(
        (result) {
          final map = result as Map;
          map['messageId'] = map.remove('in');
          map['embeddingId'] = map.remove('out');
          return MessageEmbedding.fromJson(
            Map<String, dynamic>.from(map),
          );
        },
      ).toList();
    } else {
      txn.query(sqlBuffer.toString());
      return messageEmbeddings;
    }
  }

  Future<List<Embedding>> getAllEmbeddingsOfMessage(
    String tablePrefix,
    String messageId,
  ) async {
    final messageEmbeddingTableName =
        '${tablePrefix}_${MessageEmbedding.tableName}';
    final messageTableName = '${tablePrefix}_${Message.tableName}';
    final sql = '''
SELECT ->$messageEmbeddingTableName->${tablePrefix}_${Embedding.tableName}.* 
AS Embedding FROM $messageTableName 
WHERE array::first(array::distinct(->$messageEmbeddingTableName<-$messageTableName)) == $messageId;
''';

    final results = (await _db.query(
      sql,
    ))! as List;
    if (results.isNotEmpty) {
      final result = Map<String, dynamic>.from(results.first as Map);
      final embeddings = result['Embedding'] as List;

      return embeddings
          .map(
            (result) => Embedding.fromJson(
              Map<String, dynamic>.from(
                result as Map,
              ),
            ),
          )
          .toList();
    } else {
      return List.empty();
    }
  }
}
