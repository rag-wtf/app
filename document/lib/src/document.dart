// ignore_for_file: invalid_annotation_target

import 'package:document/src/date_time_json_converter.dart';
import 'package:document/src/document_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    required int compressedFileSize,
    required String fileMimeType, // could be gzip file
    required String contentMimeType, // mime type of content of the gzip file
    @DateTimeJsonConverter() required DateTime created,
    required String? errorMessage,
    required String name,
    required int originFileSize,
    required String status,
    required int tokensCount,
    String? id,
    String? content,
    String? file,
    Object? metadata,
    @DateTimeJsonConverter() DateTime? updated,
    List<DocumentItem>? items,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
  // ignore: unused_element
  const Document._();

  static const _schema = r'''
{
  "$ref": "#/definitions/document",
  "definitions": {
    "document": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "compressedFileSize": {
          "type": "number"
        },
        "content": {
          "type": "string"
        },
        "fileMimeType": {
          "type": "string"
        },
        "contentMimeType": {
          "type": "string",
          "minLength": 1
        },
        "created": {
          "type": "string",
          "format": "date-time"
        },
        "errorMessage": {
          "type": "string"
        },
        "file": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "originFileSize": {
          "type": "number"
        },
        "status": {
          "type": "string"
        },
        "tokensCount": {
          "type": "number"
        },
        "metadata": {
          "type": "object"
        },
        "updated": {
          "type": "string",
          "format": "date-time"
        },
        "items": {
          "type": "array"
        }
      },
      "required": [
        "compressedFileSize",
        "fileMimeType",
        "contentMimeType",
        "created",
        "name",
        "originFileSize",
        "status",
        "tokensCount"
      ],
      "additionalProperties": false
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#"
}
''';

  static final jsonSchema = JsonSchema.create(_schema);

  Document validate() {
    final json = toJson();
    final results = jsonSchema.validate(json);
    if (!results.isValid) {
      return copyWith(
        errors: results.errors,
      );
    }
    return this;
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
