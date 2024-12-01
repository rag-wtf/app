import 'package:analytics/src/services/analytics_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsClient implements AnalyticsClient {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> identifyUser(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> resetUser() async {
    await _analytics.setUserId(id: 'null');
  }

  @override
  Future<void> trackScreenView(String routeName, String action) async {
    await _analytics.logScreenView(screenName: 'screen_view', parameters: {
      'name': routeName,
      'action': action,
    });
  }

  @override
  Future<void> trackChatStarted() async {
    await _analytics.logEvent(name: 'chat_started');
  }

  @override
  Future<void> trackCompressedToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'compressed_toggled',
      parameters: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackChatStartedFromPrompt() async {
    await _analytics.logEvent(name: 'chat_started_from_prompt');
  }

  @override
  Future<void> trackDataCleared({required bool keepSettings}) async {
    await _analytics.logEvent(
      name: 'data_cleared',
      parameters: {'keep_settings': keepSettings},
    );
  }

  @override
  Future<void> trackDimensionsToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'dimensions_toggled',
      parameters: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackDocumentUploadCancelled() async {
    await _analytics.logEvent(name: 'document_upload_cancelled');
  }

  @override
  Future<void> trackDocumentUploadCompleted() async {
    await _analytics.logEvent(name: 'document_upload_completed');
  }

  @override
  Future<void> trackDocumentUploadFailed() async {
    await _analytics.logEvent(name: 'document_upload_failed');
  }

  @override
  Future<void> trackDocumentsOrChatsOpened() async {
    await _analytics.logEvent(name: 'documents_or_chats_opened');
  }

  @override
  Future<void> trackEmbeddingDialogOpened() async {
    await _analytics.logEvent(name: 'embedding_dialog_opened');
  }

  @override
  Future<void> trackEmbeddingModelSelected(String name) async {
    await _analytics.logEvent(
      name: 'embedding_model_selected',
      parameters: {'model_name': name},
    );
  }

  @override
  Future<void> trackFrequencyPenaltyToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'frequency_penalty_toggled',
      parameters: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackGenerationModelSelected(String name) async {
    await _analytics.logEvent(
      name: 'generation_model_selected',
      parameters: {'model_name': name},
    );
  }

  @override
  Future<void> trackGenerationStoppedByUser() async {
    await _analytics.logEvent(name: 'generation_stopped_by_user');
  }

  @override
  Future<void> trackLlmProviderSelected(String id) async {
    await _analytics.logEvent(
      name: 'llm_provider_selected',
      parameters: {'provider_id': id},
    );
  }

  @override
  Future<void> trackPresencePenaltyToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'presence_penalty_toggled',
      parameters: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackPromptTemplateEdited() async {
    await _analytics.logEvent(name: 'prompt_template_edited');
  }

  @override
  Future<void> trackSettingsImported() async {
    await _analytics.logEvent(name: 'settings_imported');
  }

  @override
  Future<void> trackSettingsOpened() async {
    await _analytics.logEvent(name: 'settings_opened');
  }

  @override
  Future<void> trackSettingsShared() async {
    await _analytics.logEvent(name: 'settings_shared');
  }

  @override
  Future<void> trackStreamingToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'streaming_toggled',
      parameters: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackSystemPromptEdited() async {
    await _analytics.logEvent(name: 'system_prompt_edited');
  }
}
