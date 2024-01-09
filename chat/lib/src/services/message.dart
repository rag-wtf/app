// ignore_for_file: invalid_annotation_target

import 'package:chat/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    @DateTimeJsonConverter() required DateTime created,
    @DateTimeJsonConverter() required DateTime updated,
    required String userMessage,
    String? botMessage,
    String? remark,
    int? pinned,
    String? id,
    Object? metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  static const tableName = 'messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD userMessage ON {prefix}_$tableName TYPE string;
DEFINE FIELD botMessage ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD remark ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD pinned ON {prefix}_$tableName TYPE option<bool>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime;
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime;
''';
}
