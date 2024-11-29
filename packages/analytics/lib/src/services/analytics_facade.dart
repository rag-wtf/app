import 'package:analytics/src/services/analytics_client.dart';

// https://refactoring.guru/design-patterns/facade
class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this.clients);
  final List<AnalyticsClient> clients;

  @override
  Future<void> trackDocumentsOrChatsOpened() => _dispatch(
        (c) => c.trackDocumentsOrChatsOpened(),
      );

  @override
  Future<void> trackChatStarted() => _dispatch(
        (c) => c.trackChatStarted(),
      );

  @override
  Future<void> trackChatStartedFromPrompt() => _dispatch(
        (c) => c.trackChatStartedFromPrompt(),
      );

  @override
  Future<void> trackCompressedToggled({required bool enabled}) => _dispatch(
        (c) => c.trackCompressedToggled(enabled: enabled),
      );

  @override
  Future<void> trackDataCleared({required bool keepSettings}) => _dispatch(
        (c) => c.trackDataCleared(keepSettings: keepSettings),
      );

  @override
  Future<void> trackDimensionsToggled({required bool enabled}) => _dispatch(
        (c) => c.trackDimensionsToggled(enabled: enabled),
      );

  @override
  Future<void> trackDocumentUploadCancelled() => _dispatch(
        (c) => c.trackDocumentUploadCancelled(),
      );

  @override
  Future<void> trackDocumentUploadCompleted() => _dispatch(
        (c) => c.trackDocumentUploadCompleted(),
      );

  @override
  Future<void> trackDocumentUploadFailed() => _dispatch(
        (c) => c.trackDocumentUploadFailed(),
      );

  @override
  Future<void> trackEmbeddingModelSelected(String name) => _dispatch(
        (c) => c.trackEmbeddingModelSelected(name),
      );

  @override
  Future<void> trackFrequencyPenaltyToggled({required bool enabled}) =>
      _dispatch(
        (c) => c.trackFrequencyPenaltyToggled(enabled: enabled),
      );

  @override
  Future<void> trackGenerationModelSelected(String name) => _dispatch(
        (c) => c.trackGenerationModelSelected(name),
      );

  @override
  Future<void> trackGenerationStoppedByUser() => _dispatch(
        (c) => c.trackGenerationStoppedByUser(),
      );

  @override
  Future<void> trackLlmProviderSelected(String id) => _dispatch(
        (c) => c.trackLlmProviderSelected(id),
      );

  @override
  Future<void> trackPresencePenaltyToggled({required bool enabled}) =>
      _dispatch(
        (c) => c.trackPresencePenaltyToggled(enabled: enabled),
      );

  @override
  Future<void> trackPromptTemplateEdited() => _dispatch(
        (c) => c.trackPromptTemplateEdited(),
      );

  @override
  Future<void> trackSettingsImported() => _dispatch(
        (c) => c.trackSettingsImported(),
      );

  @override
  Future<void> trackSettingsOpened() => _dispatch(
        (c) => c.trackSettingsOpened(),
      );

  @override
  Future<void> trackSettingsShared() => _dispatch(
        (c) => c.trackSettingsShared(),
      );

  @override
  Future<void> trackStreamingToggled({required bool enabled}) => _dispatch(
        (c) => c.trackStreamingToggled(enabled: enabled),
      );

  @override
  Future<void> trackSystemPromptEdited() => _dispatch(
        (c) => c.trackSystemPromptEdited(),
      );

  Future<void> _dispatch(
    Future<void> Function(AnalyticsClient client) work,
  ) async {
    for (final client in clients) {
      await work(client);
    }
  }
}
