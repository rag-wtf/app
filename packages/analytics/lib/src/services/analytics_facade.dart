import 'package:analytics/src/services/analytics_client.dart';
import 'package:analytics/src/services/firebase_analytics_client.dart';
import 'package:analytics/src/services/logger_analytics_client.dart';
import 'package:analytics/src/services/mixpanel_analytics_client.dart';
import 'package:flutter/foundation.dart';

// https://refactoring.guru/design-patterns/facade
class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this.clients);
  final List<AnalyticsClient> clients;

  static Future<AnalyticsFacade> getInstance() async {
    final mixpanelAnalyticsClient = await MixpanelAnalyticsClient.getInstance();
    return AnalyticsFacade([
      mixpanelAnalyticsClient,
      FirebaseAnalyticsClient(),
      if (!kReleaseMode) LoggerAnalyticsClient(),
    ]);
  }  

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) =>
      _dispatch(
        (c) => c.setAnalyticsCollectionEnabled(enabled: enabled),
      );

  @override
  Future<void> identifyUser(String userId) => _dispatch(
        (c) => c.identifyUser(userId),
      );

  @override
  Future<void> resetUser() => _dispatch(
        (c) => c.resetUser(),
      );
  
  @override
  Future<void> trackDatabaseConnected(
    String protocol, {
    required bool autoConnect,
  }) =>
      _dispatch(
        (c) => c.trackDatabaseConnected(protocol, autoConnect: autoConnect),
      );

  @override
  Future<void> trackScreenView(String routeName, String action) => _dispatch(
        (c) => c.trackScreenView(routeName, action),
      );

  @override
  Future<void> trackChatStarted() => _dispatch(
        (c) => c.trackChatStarted(),
      );

  @override
  Future<void> trackChatStartedFromPrompt(String prompt) => _dispatch(
        (c) => c.trackChatStartedFromPrompt(prompt),
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
  Future<void> trackDocumentUploadFailed(String error) => _dispatch(
        (c) => c.trackDocumentUploadFailed(error),
      );

  @override
  Future<void> trackEmbeddingDialogOpened() => _dispatch(
        (c) => c.trackEmbeddingDialogOpened(),
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

  @override
  Future<void> trackUrlOpened(Uri url) => _dispatch(
        (c) => c.trackUrlOpened(url),
      );      

  Future<void> _dispatch(
    Future<void> Function(AnalyticsClient client) work,
  ) async {
    for (final client in clients) {
      await work(client);
    }
  }
}
