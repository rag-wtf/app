// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';

import 'package:file_upload/date_time_json_converter.dart';
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
        "compressedFileSize": {
          "type": "number"
        },
        "content": {
          "anyOf": [
            {
              "anyOf": [
                {
                  "not": {}
                },
                {
                  "type": "string"
                }
              ]
            },
            {
              "type": "null"
            }
          ]
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
          "type": ["string", "null"]
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
        }
      },
      "required": [
        "compressedFileSize",
        "contentType",
        "created",
        "errorMessage",
        "name",
        "originFileSize",
        "status",
        "updated"
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
    @DateTimeJsonConverter() required DateTime updated,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  Document validate() {
    final json = toJson();
    json.remove('id');
    final results = jsonSchema.validate(json);
    if (!results.isValid) {
      return copyWith(
        errors: results.errors,
      );
    }
    return this;
  }
}
