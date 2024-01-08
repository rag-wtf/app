import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chat/src/services/date_time_json_converter.dart';

part 'model.freezed.dart';
part 'model.g.dart';

@freezed
abstract class Model with _$Model {
  const factory Model({
    @DateTimeJsonConverter() required DateTime created,
    required String name,
    String? id,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Model;

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  static const tableName = 'sample';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMAFULL;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD updated ON {prefix}_$tableName TYPE option<datetime>;
''';
}
