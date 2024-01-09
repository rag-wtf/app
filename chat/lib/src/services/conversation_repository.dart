import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ConversationRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Conversation.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema =
        Conversation.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Conversation> createConversation(
    String tablePrefix,
    Conversation conversation, [
    Transaction? txn,
  ]) async {
    final payload = conversation.toJson();
/*    final sql = '''
CREATE ONLY ${tablePrefix}_${Conversation.tableName} 
SET name=\$name, 
    metadata=\$metadata,
    created=\$created,
    updated=\$updated; 
''';
*/
    final sql = '''
CREATE ONLY ${tablePrefix}_${Conversation.tableName} CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await _db.query(sql);

      return Conversation.fromJson(
        Map<String, dynamic>.from(
          (result! as List).first as Map,
        ),
      );
    } else {
      txn.query(sql, bindings: payload);
      return conversation;
    }
  }

  Future<List<Conversation>> getAllConversations(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final sql = '''
SELECT * FROM ${tablePrefix}_${Conversation.tableName} 
ORDER BY updated ${ascendingOrder ? 'ASC' : 'DESC'}
${page == null ? ';' : ' LIMIT $pageSize START ${page * pageSize};'}''';
    final results = (await _db.query(sql))! as List;
    return results
        .map(
          (result) => Conversation.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<int> getTotal(String tablePrefix) async {
    final sql =
        'SELECT count() FROM ${tablePrefix}_${Conversation.tableName} GROUP ALL;';
    final results = (await _db.query(sql))! as List;
    return (results.first as Map)['count'] as int;
  }

  Future<Conversation?> getConversationById(String id) async {
    final result = await _db.select(id);
    return result != null
        ? Conversation.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Conversation?> updateConversation(Conversation conversation) async {
    final payload = conversation.toJson();
    final id = payload.remove('id') as String;
    if (await _db.select(id) == null) return null;

    final result = await _db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Conversation.fromJson(
      Map<String, dynamic>.from(
        (result! as List).first as Map,
      ),
    );
  }

  Future<Conversation?> deleteConversation(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Conversation.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllConversations(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Conversation.tableName}');
  }
}
