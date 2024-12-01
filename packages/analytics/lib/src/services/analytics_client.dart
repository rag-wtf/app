abstract class AnalyticsClient {
  Future<void> setAnalyticsCollectionEnabled({required bool enabled});
  Future<void> identifyUser(String userId);
  Future<void> resetUser();
  Future<void> trackScreenView(String routeName, String action);
  Future<void> trackDocumentsOrChatsOpened();
  Future<void> trackSettingsOpened();
  Future<void> trackEmbeddingDialogOpened();
  Future<void> trackSettingsShared();
  Future<void> trackSettingsImported();
  Future<void> trackDocumentUploadCancelled();
  Future<void> trackDocumentUploadCompleted();
  Future<void> trackDocumentUploadFailed();
  Future<void> trackChatStarted();
  Future<void> trackChatStartedFromPrompt();
  Future<void> trackGenerationStoppedByUser();
  Future<void> trackLlmProviderSelected(String id);
  Future<void> trackEmbeddingModelSelected(String name);
  Future<void> trackGenerationModelSelected(String name);
  Future<void> trackDimensionsToggled({required bool enabled});
  Future<void> trackCompressedToggled({required bool enabled});
  Future<void> trackFrequencyPenaltyToggled({required bool enabled});
  Future<void> trackPresencePenaltyToggled({required bool enabled});
  Future<void> trackStreamingToggled({required bool enabled});
  Future<void> trackSystemPromptEdited();
  Future<void> trackPromptTemplateEdited();
  Future<void> trackDataCleared({required bool keepSettings});
}
