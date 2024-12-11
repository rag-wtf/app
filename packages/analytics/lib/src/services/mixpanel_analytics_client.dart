import 'package:analytics/src/env.dart';
import 'package:analytics/src/services/analytics_client.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsClient implements AnalyticsClient {
  const MixpanelAnalyticsClient(this._mixpanel);
  final Mixpanel _mixpanel;

  static Future<MixpanelAnalyticsClient> getInstance() async {
    final mixpanel = await Mixpanel.init(
      Env.mixpanelProjectToken,
      trackAutomaticEvents: true,
    );
    return MixpanelAnalyticsClient(mixpanel);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (enabled) {
      _mixpanel.optInTracking();
    } else {
      _mixpanel.optOutTracking();
    }
  }

  @override
  Future<void> identifyUser(String userId) async {
    await _mixpanel.identify(userId);
  }

  @override
  Future<void> resetUser() async {
    await _mixpanel.reset();
  }

  @override
  Future<void> trackDatabaseConnected(
    String protocol, {
    required bool autoConnect,
  }) async {
    await _mixpanel.track(
      'Database Connected',
      properties: {'protocol': protocol, 'autoConnect': autoConnect},
    );
  }

  @override
  Future<void> trackScreenView(String routeName, String action) async {
    await _mixpanel.track(
      'Screen View',
      properties: {'name': routeName, 'action': action},
    );
  }

  @override
  Future<void> trackChatStarted() async {
    await _mixpanel.track('Chat Started');
  }

  @override
  Future<void> trackChatStartedFromPrompt(String prompt) async {
    await _mixpanel.track(
      'Chat Started From Prompt',
      properties: {'prompt': prompt},
    );
  }

  @override
  Future<void> trackCompressedToggled({required bool enabled}) async {
    await _mixpanel.track(
      'Compressed Toggled',
      properties: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackDataCleared({required bool keepSettings}) async {
    await _mixpanel.track(
      'Data Cleared',
      properties: {'keepSettings': keepSettings},
    );
  }

  @override
  Future<void> trackDimensionsToggled({required bool enabled}) async {
    await _mixpanel.track(
      'Dimensions Toggled',
      properties: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackDocumentUploadCancelled() async {
    await _mixpanel.track('Document Upload Cancelled');
  }

  @override
  Future<void> trackDocumentUploadCompleted() async {
    await _mixpanel.track('Document Upload Completed');
  }

  @override
  Future<void> trackDocumentUploadFailed(String error) async {
    await _mixpanel.track(
      'Document Upload Failed',
      properties: {'error': error},
    );
  }

  @override
  Future<void> trackEmbeddingDialogOpened() async {
    await _mixpanel.track('Embedding Dialog Opened');
  }

  @override
  Future<void> trackEmbeddingModelSelected(String name) async {
    await _mixpanel.track(
      'Embedding Model Selected',
      properties: {'name': name},
    );
  }

  @override
  Future<void> trackFrequencyPenaltyToggled({required bool enabled}) async {
    await _mixpanel.track(
      'Frequency Penalty Toggled',
      properties: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackGenerationModelSelected(String name) async {
    await _mixpanel.track(
      'Generation Model Selected',
      properties: {'name': name},
    );
  }

  @override
  Future<void> trackGenerationStoppedByUser() async {
    await _mixpanel.track('Generation Stopped By User');
  }

  @override
  Future<void> trackLlmProviderSelected(String id) async {
    await _mixpanel.track(
      'LLM Provider Selected',
      properties: {'id': id},
    );
  }

  @override
  Future<void> trackPresencePenaltyToggled({required bool enabled}) async {
    await _mixpanel.track(
      'Presence Penalty Toggled',
      properties: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackPromptTemplateEdited() async {
    await _mixpanel.track('Prompt Template Edited');
  }

  @override
  Future<void> trackSettingsImported() async {
    await _mixpanel.track('Settings Imported');
  }

  @override
  Future<void> trackSettingsShared() async {
    await _mixpanel.track('Settings Shared');
  }

  @override
  Future<void> trackStreamingToggled({required bool enabled}) async {
    await _mixpanel.track(
      'Streaming Toggled',
      properties: {'enabled': enabled},
    );
  }

  @override
  Future<void> trackSystemPromptEdited() async {
    await _mixpanel.track('System Prompt Edited');
  }
}
