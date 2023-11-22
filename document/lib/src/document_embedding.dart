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
}
