import 'package:analytics/src/app/app.logger.dart';
import 'package:analytics/src/services/analytics_client.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  LoggerAnalyticsClient();
  static const _name = 'Event';
  final _log = getLogger('LoggerAnalyticsClient');

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    _log.d(
      '$_name: setAnalyticsCollectionEnabled($enabled)',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> identifyUser(String userId) async {
    _log.d('$_name: identifyUser($userId)', time: DateTime.now());
  }

  @override
  Future<void> resetUser() async {
    _log.d('$_name: resetUser', time: DateTime.now());
  }

  @override
  Future<void> trackDatabaseConnected(
    String protocol, {
    required bool autoConnect,
  }) async {
    _log.d(
      '''
$_name: trackDatabaseConnected protocol=$protocol, autoConnect=$autoConnect''',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackScreenView(String routeName, String action) async {
    _log.d(
      'Navigation: trackScreenView($routeName, $action)',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackChatStarted() async {
    _log.d('$_name: trackChatStarted', time: DateTime.now());
  }

  @override
  Future<void> trackChatStartedFromPrompt() async {
    _log.d('$_name: trackChatStartedFromPrompt', time: DateTime.now());
  }

  @override
  Future<void> trackCompressedToggled({required bool enabled}) async {
    _log.d(
      '$_name: trackCompressedToggled enabled=$enabled',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackDataCleared({required bool keepSettings}) async {
    _log.d(
      '$_name: trackDataCleared keepSettings=$keepSettings',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackDimensionsToggled({required bool enabled}) async {
    _log.d(
      '$_name: trackDimensionsToggled enabled=$enabled',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackDocumentUploadCancelled() async {
    _log.d('$_name: trackDocumentUploadCancelled', time: DateTime.now());
  }

  @override
  Future<void> trackDocumentUploadCompleted() async {
    _log.d('$_name: trackDocumentUploadCompleted', time: DateTime.now());
  }

  @override
  Future<void> trackDocumentUploadFailed() async {
    _log.d('$_name: trackDocumentUploadFailed', time: DateTime.now());
  }

  @override
  Future<void> trackDocumentsOrChatsOpened() async {
    _log.d('$_name: trackDocumentsOrChatsOpened', time: DateTime.now());
  }

  @override
  Future<void> trackEmbeddingDialogOpened() async {
    _log.d('$_name: trackEmbeddingDialogOpened', time: DateTime.now());
  }

  @override
  Future<void> trackEmbeddingModelSelected(String name) async {
    _log.d(
      '$_name: trackEmbeddingModelSelected name=$name',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackFrequencyPenaltyToggled({required bool enabled}) async {
    _log.d(
      '$_name: trackFrequencyPenaltyToggled enabled=$enabled',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackGenerationModelSelected(String name) async {
    _log.d(
      '$_name: trackGenerationModelSelected name=$name',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackGenerationStoppedByUser() async {
    _log.d('$_name: trackGenerationStoppedByUser', time: DateTime.now());
  }

  @override
  Future<void> trackLlmProviderSelected(String id) async {
    _log.d('$_name: trackLlmProviderSelected id=$id', time: DateTime.now());
  }

  @override
  Future<void> trackPresencePenaltyToggled({required bool enabled}) async {
    _log.d(
      '$_name: trackPresencePenaltyToggled enabled=$enabled',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackPromptTemplateEdited() async {
    _log.d('$_name: trackPromptTemplateEdited', time: DateTime.now());
  }

  @override
  Future<void> trackSettingsImported() async {
    _log.d('$_name: trackSettingsImported', time: DateTime.now());
  }

  @override
  Future<void> trackSettingsOpened() async {
    _log.d('$_name: trackSettingsOpened', time: DateTime.now());
  }

  @override
  Future<void> trackSettingsShared() async {
    _log.d('$_name: trackSettingsShared', time: DateTime.now());
  }

  @override
  Future<void> trackStreamingToggled({required bool enabled}) async {
    _log.d(
      '$_name: trackStreamingToggled enabled=$enabled',
      time: DateTime.now(),
    );
  }

  @override
  Future<void> trackSystemPromptEdited() async {
    _log.d('$_name: trackSystemPromptEdited', time: DateTime.now());
  }
}
