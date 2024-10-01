// ignore_for_file: invalid_annotation_target

import 'package:document/document.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'message.freezed.dart';
part 'message.g.dart';

@Freezed(toJson: true)
sealed class Message with _$Message {
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
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
    Status? status,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Embedding>? embeddings,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      authorId: json['authorId'].toString(),
      role: Role.values.byName(json['role'] as String),
      text: json['text'] as String,
      type: MessageType.values.byName(json['type'] as String),
      vote: (json['vote'] as num?)?.toInt(),
      share: (json['share'] as num?)?.toInt(),
      pinned: json['pinned'] as bool?,
      metadata: json['metadata'],
      status: json['status'] != null
          ? Status.values.byName(json['status'] as String)
          : null,
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD authorId ON {prefix}_$tableName VALUE <record>(\$value);
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
DEFINE EVENT {prefix}_${tableName}_updated ON TABLE {prefix}_$tableName 
WHEN \$event = "UPDATE" AND \$before.updated == \$after.updated THEN (
    UPDATE {prefix}_$tableName SET updated = time::now() WHERE id = \$after.id 
);
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
