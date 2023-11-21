// ignore_for_file: invalid_annotation_target

import 'package:document/src/document.dart';
import 'package:document/src/embedding.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'document_embedding.freezed.dart';
part 'document_embedding.g.dart';

@freezed
abstract class DocumentEmbedding with _$DocumentEmbedding {
  const factory DocumentEmbedding({
    required String documentId,
    required String embeddingId,
    String? id,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _DocumentEmbedding;

  factory DocumentEmbedding.fromJson(Map<String, dynamic> json) =>
      _$DocumentEmbeddingFromJson(json);

  static const _sqlSchema = '''
DEFINE TABLE DocumentEmbedding SCHEMAFULL;
DEFINE FIELD id ON DocumentEmbedding TYPE record;
DEFINE FIELD in ON DocumentEmbedding TYPE record<Document>;
DEFINE FIELD out ON DocumentEmbedding TYPE record<Embedding>;
DEFINE INDEX documentEmbeddingUniqueIndex 
    ON DocumentEmbedding 
    FIELDS in, out UNIQUE;
''';

  static String get sqlSchema => _sqlSchema;

  static const _jsonSchema = {
    r'$ref': '#/definitions/documentEmbedding',
    'definitions': {
      'documentEmbedding': {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
          },
          'documentId': {
            'type': 'string',
          },
          'embeddingId': {
            'type': 'string',
          },
        },
        'required': [
          'documentId',
          'embeddingId',
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
}
