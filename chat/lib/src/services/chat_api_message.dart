// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_api_message.freezed.dart';
part 'chat_api_message.g.dart';

enum Role {
  system,
  user,
  assistant,
  function,
}

@Freezed(toJson: true)
sealed class ChatApiMessage with _$ChatApiMessage {
  const factory ChatApiMessage({
    required Role role,
    required String content,
    @JsonKey(includeToJson: false) required DateTime dateTime,
  }) = _ChatApiMessage;

  factory ChatApiMessage.fromJson(Map<String, dynamic> json) {
    return ChatApiMessage(
      role: Role.values.byName(json['role'] as String),
      content: json['content'] as String,
      dateTime: json['dateTime'] as DateTime,
    );
  }
}
