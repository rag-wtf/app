// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum Role {
  system,
  user,
  assistant,
  function,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required Role role,
    required String content,
    @JsonKey(includeToJson: false) required DateTime dateTime,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
