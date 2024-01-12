import 'package:chat/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String name,
    @DateTimeJsonConverter() required DateTime created,
    @DateTimeJsonConverter() required DateTime? updated,
    String? id,
    bool? pinned,
    Object? metadata,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  static const tableName = 'chats';

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

class ChatList {
  const ChatList(this.items, this.total);
  final List<Chat> items;
  final int total;
}
