import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:settings/src/services/date_time_json_converter.dart';
part 'setting.freezed.dart';
part 'setting.g.dart';

@freezed
abstract class Setting with _$Setting {
  const factory Setting({
    required String key,
    required String value,
    @DateTimeJsonConverter() required DateTime created,
    String? id,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Setting;

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  static const sqlSchema = '''
DEFINE TABLE {prefix}_settings SCHEMAFULL;
DEFINE FIELD id ON {prefix}_settings TYPE record;
DEFINE FIELD key ON {prefix}_settings TYPE string;
DEFINE FIELD value ON {prefix}_settings TYPE string;
DEFINE FIELD created ON {prefix}_settings TYPE datetime;
DEFINE FIELD updated ON {prefix}_settings TYPE option<datetime>;
DEFINE INDEX key_index ON {prefix}_settings COLUMNS key UNIQUE;
''';

  static const tableName = 'settings';
}
