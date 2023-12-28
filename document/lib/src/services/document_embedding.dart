import 'package:document/src/services/document.dart';
import 'package:document/src/services/embedding.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'document_embedding.freezed.dart';
part 'document_embedding.g.dart';

@freezed
abstract class DocumentEmbedding with _$DocumentEmbedding {
  const factory DocumentEmbedding({
    required String documentId,
    required String embeddingId,
    String? id,
  }) = _DocumentEmbedding;

  factory DocumentEmbedding.fromJson(Map<String, dynamic> json) =>
      _$DocumentEmbeddingFromJson(json);

  static const tableName = 'document_embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMAFULL;
DEFINE FIELD id ON {prefix}_$tableName TYPE record;
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Document.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Embedding.tableName}>;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
