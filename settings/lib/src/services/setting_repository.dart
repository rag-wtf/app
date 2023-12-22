import 'dart:convert';

import 'package:settings/src/services/setting.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class SettingRepository {
  const SettingRepository({
    required this.db,
  });
  final Surreal db;

  Future<bool> isSchemaCreated(String prefix) async {
    final results = (await db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${prefix}_${Setting.tableName}');
  }

  Future<void> createSchema(
    String prefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Setting.sqlSchema.replaceAll('{prefix}', prefix);
    txn == null ? await db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Setting> createSetting(
    String prefix,
    Setting setting, [
    Transaction? txn,
  ]) async {
    final payload = setting.toJson();
    final sql = '''
CREATE ONLY ${prefix}_${Setting.tableName} CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await db.query(sql);

      return Setting.fromJson(
        Map<String, dynamic>.from(
          (result! as List).first as Map,
        ),
      );
    } else {
      txn.query(sql);
      return setting;
    }
  }

  Future<List<Setting>> getAllSettings(String prefix) async {
    final results = (await db
        .query('SELECT * FROM ${prefix}_${Setting.tableName}'))! as List;
    return results
        .map(
          (result) => Setting.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<Setting?> getSettingById(String id) async {
    final result = await db.select(id);
    return result != null
        ? Setting.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Setting?> getSettingByKey(String prefix, String key) async {
    final sql = '''
SELECT * FROM ${prefix}_${Setting.tableName}
WHERE key = "$key" 
LIMIT 1
''';
    final result = await db.query(sql);

    return result != null && (result as List).isNotEmpty
        ? Setting.fromJson(
            Map<String, dynamic>.from(
              result.first as Map,
            ),
          )
        : null;
  }

  Future<Setting?> updateSetting(Setting setting) async {
    final payload = setting.toJson();
    final id = payload.remove('id') as String;
    if (await db.select(id) == null) return null;

    final result = await db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Setting.fromJson(
      Map<String, dynamic>.from(
        (result! as List).first as Map,
      ),
    );
  }

  Future<Setting?> deleteSetting(String id) async {
    final result = await db.delete(id);

    return result != null
        ? Setting.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllSettings(String prefix) async {
    await db.delete('${prefix}_${Setting.tableName}');
  }
}
