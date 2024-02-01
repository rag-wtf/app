// ignore_for_file: invalid_annotation_target

import 'package:document/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    required int compressedFileSize,
    required String fileMimeType, // could be gzip file
    required String name,
    required int originFileSize,
    required DocumentStatus status,
    String? id,
    String? content,
    String? contentMimeType, // mime type of content of the gzip file
    String? file,
    Object? metadata,
    String? errorMessage,
    @DateTimeJsonConverter() DateTime? splitted,
    @DateTimeJsonConverter() DateTime? indexed,
    @DateTimeJsonConverter() DateTime? done, // completed/failed/canceled
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<List<int>>? byteData,
    @DateTimeJsonConverter() DateTime? created,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  static const tableName = 'documents';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD compressedFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD content ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD fileMimeType ON {prefix}_$tableName TYPE string;
DEFINE FIELD contentMimeType ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD errorMessage ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD file ON {prefix}_$tableName TYPE option<string>;
DEFINE FIELD name ON {prefix}_$tableName TYPE string;
DEFINE FIELD originFileSize ON {prefix}_$tableName TYPE number;
DEFINE FIELD status ON {prefix}_$tableName TYPE string;
DEFINE FIELD splitted ON {prefix}_$tableName TYPE option<datetime>;
DEFINE FIELD indexed ON {prefix}_$tableName TYPE option<datetime>;
DEFINE FIELD done ON {prefix}_$tableName TYPE option<datetime>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
''';

  static const _jsonSchema = {
    r'$ref': '#/definitions/document',
    'definitions': {
      'document': {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
          },
          'compressedFileSize': {
            'type': 'number',
          },
          'content': {
            'type': 'string',
          },
          'fileMimeType': {
            'type': 'string',
          },
          'contentMimeType': {
            'type': 'string',
            'minLength': 1,
          },
          'created': {
            'type': 'string',
            'format': 'date-time',
          },
          'errorMessage': {
            'type': 'string',
          },
          'file': {
            'type': 'string',
          },
          'name': {
            'type': 'string',
          },
          'originFileSize': {
            'type': 'number',
          },
          'status': {
            'type': 'string',
          },
          'metadata': {
            'type': 'object',
          },
          'updated': {
            'type': 'string',
            'format': 'date-time',
          },
          'splitted': {
            'type': 'string',
            'format': 'date-time',
          },
          'indexed': {
            'type': 'string',
            'format': 'date-time',
          },
          'done': {
            'type': 'string',
            'format': 'date-time',
          },
        },
        'required': [
          'compressedFileSize',
          'fileMimeType',
          'name',
          'originFileSize',
          'status',
        ],
        'additionalProperties': false,
      },
    },
    r'$schema': 'http://json-schema.org/draft-07/schema#',
  };

  static final jsonSchema = JsonSchema.create(_jsonSchema);

  static List<ValidationError>? validate(Map<String, dynamic> json) {
    final results = jsonSchema.validate(json);
    if (!results.isValid) {
      return results.errors;
    }
    return null;
  }

  static dynamic toMap(dynamic input) {
    if (input is Map) {
      final result = <String, dynamic>{};
      input.forEach((key, value) {
        result[key.toString()] = toMap(value);
      });
      return result;
    } else if (input is List) {
      final result = <dynamic>[];
      for (final item in input) {
        result.add(toMap(item));
      }
      return result;
    } else {
      return input;
    }
  }
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
