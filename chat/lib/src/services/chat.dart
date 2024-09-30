// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@Freezed(toJson: true)
sealed class Chat with _$Chat {
  const factory Chat({
    required String name,
    String? id,
    int? vote,
    int? share,
    bool? pinned,
    Object? metadata,
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'].toString(),
      name: json['name'] as String,
      vote: (json['vote'] as num?)?.toInt(),
      share: (json['share'] as num?)?.toInt(),
      pinned: json['pinned'] as bool?,
      metadata: json['metadata'],
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'chats';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
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

class ChatList {
  const ChatList(this.items, this.total);
  final List<Chat> items;
  final int total;
}
