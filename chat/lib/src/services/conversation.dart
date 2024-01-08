import 'package:chat/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    @DateTimeJsonConverter() required DateTime created,
    @DateTimeJsonConverter() required DateTime? updated,
    required String name,
    String? id,
    bool? pinned,
    Object? metadata,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  static const tableName = 'conversations';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD pinned ON {prefix}_$tableName TYPE option<bool>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime;
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime;
''';
//DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
}
