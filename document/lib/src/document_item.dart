// ignore_for_file: invalid_annotation_target

import 'package:document/src/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'document_item.freezed.dart';
part 'document_item.g.dart';

@freezed
abstract class DocumentItem with _$DocumentItem {
  const factory DocumentItem({
    required String content,
    required List<double> embedding,
    required Object metadata,
    required int tokensCount,
    String? id,
    @DateTimeJsonConverter() DateTime? updated,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _DocumentItem;

  factory DocumentItem.fromJson(Map<String, dynamic> json) =>
      _$DocumentItemFromJson(json);
  // ignore: unused_element
  const DocumentItem._();

  static const _schema = r'''
{
  "$ref": "#/definitions/document_item",
  "definitions": {
    "document_item": {
      "type": "object",
      "properties": {
        "content": {
          "type": "string"
        },
        "embedding": {
          "type": "array",
          "items": { "type": "number", "format": "float" },
          "description": "An array of float numbers representing embedding data."
        },
        "metadata": {
          "type": "object"
        },
        "tokensCount": {
          "type": "number"
        },
        "updated": {
          "type": "string",
          "format": "date-time"
        }
      },
      "required": [
        "content",
        "embedding",
        "metadata",
        "tokensCount"
      ],
      "additionalProperties": false
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#"
}
''';

  static final jsonSchema = JsonSchema.create(_schema);

  DocumentItem validate() {
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
