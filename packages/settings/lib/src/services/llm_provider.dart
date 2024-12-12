import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_provider.freezed.dart';
part 'llm_provider.g.dart';

@freezed
sealed class LlmProvider with _$LlmProvider {
  const factory LlmProvider({
    required String id,
    required String name,
    required String baseUrl,    
    required Embeddings embeddings,
    required ChatCompletions chatCompletions,
    required String website,
    String? apiKeyUrl,
    @Default(false) bool litellm,
  }) = _LlmProvider;

  factory LlmProvider.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderFromJson(json);
}

@freezed
sealed class Embeddings with _$Embeddings {
  const factory Embeddings({
    required String model,
    required List<EmbeddingModel> models,
    String? apiKeyUrl,
    int? dimensions,
    String? name,
    int? maxBatchSize,
    String? website,
    @Default(true) bool dimensionsEnabled,
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
    required List<String> stop,
    required List<ChatModel> models,
    String? apiKeyUrl,
    double? frequencyPenalty,
    String? name,
    double? presencePenalty,
    String? website,
    @Default(true) bool frequencyPenaltyEnabled,
    @Default(true) bool presencePenaltyEnabled,
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

  factory ChatModel.nullObject() {
    return const ChatModel(
      name: 'null',
      contextLength: 0,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
}
