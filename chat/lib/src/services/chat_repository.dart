import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class ChatRepository {
  final _db = locator<Surreal>();
  final _log = getLogger('ChatRepository');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Chat.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Chat.sqlSchema.replaceAll('{prefix}', tablePrefix);
    _log.d(sqlSchema);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Chat> createChat(
    String tablePrefix,
    Chat chat, [
    Transaction? txn,
  ]) async {
    final payload = chat.toJson();
/*    final sql = '''
CREATE ONLY ${tablePrefix}_${Chat.tableName} 
SET name=\$name, 
    metadata=\$metadata,
    created=\$created,
    updated=\$updated; 
''';
*/
    final sql = '''
CREATE ONLY ${tablePrefix}_${Chat.tableName} CONTENT ${jsonEncode(payload)};''';
    _log.d(sql);
    if (txn == null) {
      final result = await _db.query(sql);

      return Chat.fromJson(
        Map<String, dynamic>.from(
          result! as Map,
        ),
      );
    } else {
      txn.query(sql, bindings: payload);
      return chat;
    }
  }

  Future<List<Chat>> getAllChats(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final sql = '''
SELECT * FROM ${tablePrefix}_${Chat.tableName} 
ORDER BY updated ${ascendingOrder ? 'ASC' : 'DESC'}
${page == null ? ';' : ' LIMIT $pageSize START ${page * pageSize};'}''';
    final results = (await _db.query(sql))! as List;
    return results
        .map(
          (result) => Chat.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Chat.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return results.isNotEmpty ? (results.first as Map)['count'] as int : 0;
  }

  Future<Chat?> getChatById(String id) async {
    final result = await _db.select(id);
    return result != null
        ? Chat.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Chat?> updateChat(Chat chat) async {
    if (await _db.select(chat.id!) == null) return null;

    final payload = chat.toJson();
    final id = payload.remove('id') as String;
    final sql = 'UPDATE ONLY $id MERGE ${jsonEncode(payload)}';
    _log.d(sql);
    final result = await _db.query(sql);
    return Chat.fromJson(
      Map<String, dynamic>.from(
        result! as Map,
      ),
    );
  }

  Future<Chat?> deleteChat(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Chat.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllChats(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Chat.tableName}');
  }
}
