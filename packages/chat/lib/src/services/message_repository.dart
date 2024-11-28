import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/message.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class MessageRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('MessageRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Message.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix,
    String dimensions, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Message.sqlSchema
        .replaceAll('{prefix}', tablePrefix)
        .replaceFirst('{dimensions}', dimensions);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<String?> redefineEmbeddingIndex(
    String tablePrefix,
    String dimensions,
  ) async {
    _log.d('redefineEmbeddingIndex($tablePrefix, $dimensions)');
    final total = await getTotal(tablePrefix);
    if (total > 0) {
      return '''
Cannot change dimensions, there are existing embeddings in the database.''';
    } else {
      final sql = Message.defineEmbeddingsMtreeIndex
          .replaceAll('{prefix}', tablePrefix)
          .replaceFirst('{dimensions}', dimensions);
      await _db.query(sql);
      return null;
    }
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Message.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return results.isEmpty ? 0 : (results.first as Map)['count'] as int;
  }

  Future<Message> createMessage(
    String tablePrefix,
    Message message, [
    Transaction? txn,
  ]) async {
    final payload = message.toJson();
    final sql = '''
CREATE ONLY ${tablePrefix}_${Message.tableName} 
CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await _db.query(sql);

      return Message.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return message;
    }
  }

  Future<List<Message>> getAllMessages(String tablePrefix) async {
    final results = (await _db
        .query('SELECT * FROM ${tablePrefix}_${Message.tableName}'))! as List;
    return results
        .map(
          (result) => Message.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<Message?> getMessageById(String id) async {
    final result = await _db.select(id);

    return result != null
        ? Message.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Message?> updateMessage(
    Message message, [
    Transaction? txn,
  ]) async {
    if (await _db.select(message.id!) == null) return null;

    final payload = message.toJson();
    final id = payload.remove('id') as String;
    final sql = 'UPDATE ONLY $id MERGE ${jsonEncode(payload)};';
    if (txn == null) {
      final result = await _db.query(sql);
      return Message.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql);
      return null;
    }
  }

  Future<Message?> deleteMessage(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Message.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllMessages(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Message.tableName}');
  }
}
