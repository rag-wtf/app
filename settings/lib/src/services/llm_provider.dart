import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_provider.freezed.dart';
part 'llm_provider.g.dart';

@freezed
sealed class LlmProvider with _$LlmProvider {
  const factory LlmProvider({
    required String name,
    required String baseUrl,
    required Embeddings embeddings,
    required ChatCompletions chatCompletions,
  }) = _LlmProvider;

  factory LlmProvider.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderFromJson(json);
}

@freezed
sealed class Embeddings with _$Embeddings {
  const factory Embeddings({
    required String model,
    required List<EmbeddingModel> models,
    int? dimensions,
  }) = _Embeddings;

  factory Embeddings.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingsFromJson(json);
}

@freezed
sealed class EmbeddingModel with _$EmbeddingModel {
  const factory EmbeddingModel({
    required String name,
    required int dimensions,
    required int contextLength,
  }) = _EmbeddingModel;

  factory EmbeddingModel.nullObject() {
    return const EmbeddingModel(
      name: 'null',
      dimensions: 0,
      contextLength: 0,
    );
  }

  factory EmbeddingModel.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingModelFromJson(json);
}

@freezed
sealed class ChatCompletions with _$ChatCompletions {
  const factory ChatCompletions({
    required String model,
    required double temperature,
    required int maxTokens,
    required double topP,
    required double frequencyPenalty,
    required double presencePenalty,
    required List<String> stop,
    required List<ChatModel> models,
  }) = _ChatCompletions;

  factory ChatCompletions.fromJson(Map<String, dynamic> json) =>
      _$ChatCompletionsFromJson(json);
}

@freezed
sealed class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String name,
    required int contextLength,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
}
