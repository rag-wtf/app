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
    required String authorId,
    required String text,
    required MessageType type,
    int? pinned,
    String? id,
    Object? metadata,
    Status? status,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  static const tableName = 'messages';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD authorId ON {prefix}_$tableName TYPE record;
DEFINE FIELD text ON {prefix}_$tableName TYPE string;
DEFINE FIELD type ON {prefix}_$tableName TYPE string;
DEFINE FIELD status ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD pinned ON {prefix}_$tableName TYPE option<bool>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime;
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime;
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
  video
}

/// All possible statuses message can have.
enum Status { error, seen, sending, sent }
