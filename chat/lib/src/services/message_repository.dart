import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/message.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class MessageRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Message.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Message.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
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
