// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'embedding.freezed.dart';
part 'embedding.g.dart';

@Freezed(toJson: true)
sealed class Embedding with _$Embedding {
  const factory Embedding({
    required String content,
    List<double>? embedding,
    String? id,
    Object? metadata,
    @JsonKey(includeToJson: false) double? score,
    @JsonKey(includeToJson: false) DateTime? created,
    @JsonKey(includeToJson: false) DateTime? updated,
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
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD content ON {prefix}_$tableName TYPE string;
DEFINE FIELD embedding ON {prefix}_$tableName TYPE option<array<float>>;
DEFINE FIELD metadata ON {prefix}_$tableName TYPE option<object>;
DEFINE FIELD created ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
DEFINE FIELD updated ON {prefix}_$tableName TYPE datetime DEFAULT time::now();
$defineEmbeddingsMtreeIndex
DEFINE EVENT {prefix}_${tableName}_updated ON TABLE {prefix}_$tableName 
WHEN \$event = "UPDATE" AND \$before.updated == \$after.updated THEN (
    UPDATE {prefix}_$tableName SET updated = time::now() WHERE id = \$after.id 
);
''';

  // 65535 is the maximum value of an unsigned 16-bit integer
  static const defineEmbeddingsMtreeIndex = '''
DEFINE INDEX OVERWRITE {prefix}_${tableName}_mtree_index ON {prefix}_$tableName 
FIELDS embedding MTREE DIMENSION {dimensions} DIST COSINE TYPE F32
CAPACITY 65535;
''';

  static const rebuildEmbeddingsMtreeIndex = '''
REBUILD INDEX {prefix}_${tableName}_mtree_index ON {prefix}_$tableName;
''';
}
