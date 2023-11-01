// ignore_for_file: invalid_annotation_target

import 'package:file_upload/date_time_json_converter.dart';
import 'package:file_upload/document_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class Document with _$Document {
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
        "contentType": {
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
        "updated": {
          "type": "string",
          "format": "date-time"
        },
        "items": {
          "type": ["array", "null"]
        }
      },
      "required": [
        "compressedFileSize",
        "contentType",
        "created",
        "errorMessage",
        "name",
        "originFileSize",
        "status"
      ],
      "additionalProperties": false
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#"
}
''';

  static final jsonSchema = JsonSchema.create(_schema);

  const factory Document({
    String? id,
    required int compressedFileSize,
    String? content,
    required String contentType,
    @DateTimeJsonConverter() required DateTime created,
    required String errorMessage,
    String? file,
    required String name,
    required int originFileSize,
    required String status,
    @DateTimeJsonConverter() DateTime? updated,
    List<DocumentItem>? items,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

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
}
