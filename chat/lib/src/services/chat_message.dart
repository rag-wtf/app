import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String chatId,
    required String messageId,
    String? id,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  static const tableName = 'chat_messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Chat.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Message.tableName}>;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
