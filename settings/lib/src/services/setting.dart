import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:settings/src/services/date_time_json_converter.dart';
part 'setting.freezed.dart';
part 'setting.g.dart';

@freezed
abstract class Setting with _$Setting {
  const factory Setting({
    required String key,
    required String value,
    String? id,
    @DateTimeJsonConverter() DateTime? created,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Setting;

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  static const tableName = 'settings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD key ON {prefix}_$tableName TYPE string;
DEFINE FIELD value ON {prefix}_$tableName TYPE string;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
''';
}
