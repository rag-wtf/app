// ignore_for_file: invalid_annotation_target

import 'package:document/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'embedding.freezed.dart';
part 'embedding.g.dart';

@freezed
abstract class Embedding with _$Embedding {
  const factory Embedding({
    required String content,
    required List<double> embedding,
    required int tokensCount,
    Object? metadata,
    String? id,
    @DateTimeJsonConverter() DateTime? updated,
    @JsonKey(includeToJson: false) double? score,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
  }) = _Embedding;

  factory Embedding.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingFromJson(json);

  static const tableName = 'embeddings';

  static const sqlSchema = '''
DEFINE INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName 
FIELDS embedding MTREE DIMENSION 384 DIST COSINE;
''';

  static const _jsonSchema = {
    r'$ref': '#/definitions/embedding',
    'definitions': {
      'embedding': {
        'type': 'object',
        'properties': {
          'id': {
            'type': 'string',
          },
          'content': {
            'type': 'string',
            'minLength': 1,
          },
          'embedding': {
            'type': 'array',
            'items': {
              'type': 'number',
              'format': 'float',
            },
            'description':
                'An array of float numbers representing embedding data.',
          },
          'metadata': {
            'type': 'object',
          },
          'tokensCount': {
            'type': 'number',
          },
          'updated': {
            'type': 'string',
            'format': 'date-time',
          },
          'score': {
            'type': 'number',
            'format': 'float',
          },
        },
        'required': [
          'content',
          'embedding',
          'tokensCount',
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
