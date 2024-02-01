// ignore_for_file: invalid_annotation_target

import 'package:chat/src/services/date_time_json_converter.dart';
import 'package:document/document.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String authorId,
    required Role role,
    required String text,
    required MessageType type,
    String? id,
    int? vote,
    int? share,
    bool? pinned,
    Object? metadata,
    @DateTimeJsonConverter() DateTime? created,
    @DateTimeJsonConverter() DateTime? updated,
    Status? status,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Embedding>? embeddings,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  static const tableName = 'messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD authorId ON {prefix}_$tableName TYPE record;
DEFINE FIELD role ON {prefix}_$tableName TYPE string;
DEFINE FIELD text ON {prefix}_$tableName TYPE string;
DEFINE FIELD type ON {prefix}_$tableName TYPE string;
DEFINE FIELD status ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD vote ON {prefix}_$tableName TYPE number DEFAULT 0;
DEFINE FIELD share ON {prefix}_$tableName TYPE number DEFAULT 0;
DEFINE FIELD pinned ON {prefix}_$tableName TYPE option<bool>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
''';
}

enum MessageType {
  audio,
  custom,
  file,
  image,
  system,
  text,
  unsupported,
  video,
}

/// All possible statuses message can have.
enum Status { error, seen, sending, sent }

enum Role { user, agent }

class MessageList {
  const MessageList(this.items, this.total);
  final List<Message> items;
  final int total;
}
