import 'package:document/src/services/document.dart';
import 'package:document/src/services/embedding.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'document_embedding.freezed.dart';
part 'document_embedding.g.dart';

@Freezed(toJson: true)
sealed class DocumentEmbedding with _$DocumentEmbedding {
  const factory DocumentEmbedding({
    required String documentId,
    required String embeddingId,
    String? id,
  }) = _DocumentEmbedding;

  factory DocumentEmbedding.fromJson(Map<String, dynamic> json) {
    return DocumentEmbedding(
      id: json['id'].toString(),
      documentId: json['documentId'] as String,
      embeddingId: json['embeddingId'] as String,
    );
  }

  static const tableName = 'document_embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Document.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Embedding.tableName}>;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
