import 'package:chat/src/services/message.dart';
import 'package:document/document.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'message_embedding.freezed.dart';
part 'message_embedding.g.dart';

@Freezed(toJson: true)
sealed class MessageEmbedding with _$MessageEmbedding {
  const factory MessageEmbedding({
    required String messageId,
    required String embeddingId,
    required String searchType,
    required double score,
    String? id,
  }) = _MessageEmbedding;

  factory MessageEmbedding.fromJson(Map<String, dynamic> json) {
    return MessageEmbedding(
      id: json['id'].toString(),
      messageId: json['messageId'] as String,
      embeddingId: json['embeddingId'] as String,
      searchType: json['searchType'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  static const tableName = 'message_embeddings';

  static const sqlSchema = '''
DEFINE TABLE {prefix}_$tableName SCHEMALESS;
DEFINE FIELD id ON {prefix}_$tableName VALUE <record>(\$value);
DEFINE FIELD in ON {prefix}_$tableName TYPE record<{prefix}_${Message.tableName}>;
DEFINE FIELD out ON {prefix}_$tableName TYPE record<{prefix}_${Embedding.tableName}>;
DEFINE FIELD searchType ON {prefix}_$tableName TYPE string;
DEFINE FIELD score ON {prefix}_$tableName TYPE number;
DEFINE INDEX {prefix}_${tableName}_unique_index 
    ON {prefix}_$tableName 
    FIELDS in, out UNIQUE;
''';
}
