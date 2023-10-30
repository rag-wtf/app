// ignore_for_file: invalid_annotation_target

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
import 'uint8_list_json_converter.dart';
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
        "file": {},
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
    required String created,
    required String errorMessage,
    @Uint8ListJsonConverter() required Uint8List file,
    required String name,
    required int originFileSize,
    required String status,
    required String updated,
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
