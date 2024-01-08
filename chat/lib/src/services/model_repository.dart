import 'dart:convert';

import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/services/model.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class ModelRepository {
  final _db = locator<Surreal>();

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Model.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    final sqlSchema = Model.sqlSchema.replaceAll('{prefix}', tablePrefix);
    txn == null ? await _db.query(sqlSchema) : txn.query(sqlSchema);
  }

  Future<Model> createModel(
    String tablePrefix,
    Model model, [
    Transaction? txn,
  ]) async {
    final payload = model.toJson();
    final sql = '''
CREATE ONLY ${tablePrefix}_${Model.tableName} CONTENT ${jsonEncode(payload)};''';
    if (txn == null) {
      final result = await _db.query(sql);

      return Model.fromJson(
        Map<String, dynamic>.from(
          (result! as List).first as Map,
        ),
      );
    } else {
      txn.query(sql);
      return model;
    }
  }

  Future<List<Model>> getAllModels(String tablePrefix) async {
    final results = (await _db
        .query('SELECT * FROM ${tablePrefix}_${Model.tableName}'))! as List;
    return results
        .map(
          (result) => Model.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          ),
        )
        .toList();
  }

  Future<Model?> getModelById(String id) async {
    final result = await _db.select(id);
    return result != null
        ? Model.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<Model?> updateModel(Model model) async {
    final payload = model.toJson();
    final id = payload.remove('id') as String;
    if (await _db.select(id) == null) return null;

    final result = await _db.query(
      'UPDATE ONLY $id MERGE ${jsonEncode(payload)}',
    );

    return Model.fromJson(
      Map<String, dynamic>.from(
        (result! as List).first as Map,
      ),
    );
  }

  Future<Model?> deleteModel(String id) async {
    final result = await _db.delete(id);

    return result != null
        ? Model.fromJson(
            Map<String, dynamic>.from(
              result as Map,
            ),
          )
        : null;
  }

  Future<void> deleteAllModels(String tablePrefix) async {
    await _db.delete('${tablePrefix}_${Model.tableName}');
  }
}
