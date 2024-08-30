// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';
import 'package:document/src/services/null_json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'document.freezed.dart';
part 'document.g.dart';

@Freezed(toJson: true)
sealed class Document with _$Document {
  const factory Document({
    required int compressedFileSize,
    required String fileMimeType, // could be gzip file
    required String name,
    required int originFileSize,
    required DocumentStatus status,
    String? id,
    String? content,
    String? contentMimeType, // mime type of content of the gzip file
    @JsonKey(includeToJson: false) Uint8List? file,
    Object? metadata,
    String? errorMessage,
    @NullDateTimeJsonConverter() DateTime? splitted,
    @NullDateTimeJsonConverter() DateTime? done, // completed/failed/canceled
    @JsonKey(includeFromJson: false, includeToJson: false)
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<List<int>>? byteData,
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'].toString(),
      compressedFileSize: json['compressedFileSize'] as int,
      fileMimeType: json['fileMimeType'] as String,
      name: json['name'] as String,
      originFileSize: json['originFileSize'] as int,
      status: DocumentStatus.values.byName(json['status'] as String),
      content: json['content'] as String?,
      contentMimeType: json['contentMimeType'] as String?,
      file: json['file'] != null
          ? (json['file'] as ByteBuffer).asUint8List()
          : null,
      metadata: json['metadata'],
      errorMessage: json['errorMessage'] as String?,
      splitted: json['splitted'] as DateTime?,
      done: json['done'] as DateTime?,
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'documents';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD compressedFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD content ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD fileMimeType ON {prefix}_$tableName TYPE string;
DEFINE FIELD contentMimeType ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD errorMessage ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD file ON {prefix}_$tableName TYPE option<bytes>;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD originFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD status ON {prefix}_$tableName TYPE string;
DEFINE FIELD splitted ON {prefix}_$tableName TYPE datetime DEFAULT time::from::unix(0);
DEFINE FIELD done ON {prefix}_$tableName TYPE datetime DEFAULT time::from::unix(0);
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE EVENT {prefix}_${tableName}_updated ON TABLE {prefix}_$tableName 
WHEN \$event = "UPDATE" AND \$before.updated == \$after.updated THEN (
    UPDATE {prefix}_$tableName SET updated = time::now() WHERE id = \$after.id 
);
''';
}

enum DocumentStatus {
  created,
  pending,
  splitting,
  indexing,
  completed,
  failed,
  canceled,
}

class DocumentList {
  const DocumentList(this.items, this.total);
  final List<Document> items;
  final int total;
}
