// ignore_for_file: invalid_annotation_target

import 'package:document/src/services/date_time_json_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_schema/json_schema.dart';
part 'embedding.freezed.dart';
part 'embedding.g.dart';

@Freezed(toJson: true)
sealed class Embedding with _$Embedding {
  const factory Embedding({
    required String content,
    required List<double> embedding,
    String? id,
    @JsonKey(includeToJson: false) double? score,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationError>? errors,
    Object? metadata,
    @DateTimeJsonConverter() DateTime? created,
    @DateTimeJsonConverter() DateTime? updated,
  }) = _Embedding;

  factory Embedding.fromJson(Map<String, dynamic> json) {
    return Embedding(
      id: json['id'].toString(),
      content: json['content'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      score: (json['score'] as num?)?.toDouble(),
      metadata: json['metadata'],
      created: json['created'] as DateTime,
      updated: json['updated'] as DateTime,
    );
  }

  static const tableName = 'embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD content ON {prefix}_$tableName TYPE string;
DEFINE FIELD embedding ON {prefix}_$tableName TYPE array<float>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
$_defineEmbeddingsMtreeIndex
''';

  static const _defineEmbeddingsMtreeIndex = '''
DEFINE INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName 
FIELDS embedding MTREE DIMENSION {dimensions} DIST COSINE;
''';

  static const redefineEmbeddingsMtreeIndex = '''
REMOVE INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName;
$_defineEmbeddingsMtreeIndex
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
          'created': {
            'type': 'string',
            'format': 'date-time',
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
