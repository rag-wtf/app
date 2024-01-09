import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'conversation_message.freezed.dart';
part 'conversation_message.g.dart';

@freezed
abstract class ConversationMessage with _$ConversationMessage {
  const factory ConversationMessage({
    required String conversationId,
    required String messageId,
    String? id,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);

  static const tableName = 'conversation_messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMAFULL;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Conversation.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Message.tableName}>;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
