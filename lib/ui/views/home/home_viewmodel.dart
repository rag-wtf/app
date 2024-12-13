import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:chat/chat.dart';
import 'package:database/database.dart';
import 'package:document/document.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/app/app.logger.dart';
import 'package:rag/ui/common/app_strings.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({this.tablePrefix = defaultTablePrefix});
  final String tablePrefix;

  final _connectionSettingService = locator<ConnectionSettingService>();
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _settingService = locator<SettingService>();
  final _documentService = locator<DocumentService>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _chatRepository = locator<ChatRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _chatService = locator<ChatService>();
  final _analyticsFacade = locator<AnalyticsFacade>();
  // ignore: unused_field
  final _log = getLogger('HomeViewModel');
  int get totalChats => _totalChats;
  late int _totalChats;

  late String _appName;
  String get appName => _appName;
  late String _version;
  String get version => _version;
  late String _buildNumber;
  String get buildNumber => _buildNumber;

  bool _isKeepSettings = true;
  bool get isKeepSettings => _isKeepSettings;
  set isKeepSettings(bool value) {
    _isKeepSettings = value;
    notifyListeners();
  }

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  String getSettingValue(String key) {
    final setting = _settingService.get(key);
    return setting.value;
  }

  Future<String?> Function(
    String tablePrefix,
    String dimensions,
  )? get redefineEmbeddingIndexFunction => _redefineEmbeddingIndex;

  Future<String?> _redefineEmbeddingIndex(
    String tablePrefix,
    String dimensions,
  ) async {
    _log.d('redefineEmbeddingIndex($tablePrefix, $dimensions)');
    final embeddingTotal = await _embeddingRepository.getTotal(tablePrefix);
    final messageTotal = await _messageRepository.getTotal(tablePrefix);
    if (embeddingTotal > 0 || messageTotal > 0) {
      return '''
Cannot change dimensions, there are existing embeddings in the database.''';
    } else {
      await _embeddingRepository.redefineEmbeddingIndex(
        tablePrefix,
        dimensions,
      );
      await _messageRepository.redefineEmbeddingIndex(
        tablePrefix,
        dimensions,
      );
      return null;
    }
  }

  Future<void> initialise() async {
    setBusy(true);
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    await _connectDatabase();
    setBusy(false);
  }

  Future<void> _connectDatabase() async {
    var confirmed = false;
    var analyticsEnabled = true;

    if (!await _connectionSettingService.autoConnect()) {
      while (!confirmed) {
        final response = await _dialogService.showCustomDialog<bool, void>(
          variant: DialogType.connection,
          title: 'Database Login',
          description: '''
Experience the app with SurrealDB's Memory or IndexedDB mode, keeping your data stored locally in your browser.
For a secure and permanent solution, easily create a free SurrealDB instance on Surreal Cloud.
''',
        );

        confirmed = response?.confirmed ?? false;
        analyticsEnabled = response?.data ?? true;
      }
    }
    _appName =
        await _connectionSettingService.getCurrentConnectionName() ?? appTitle;
    await _settingService.initialise(
      tablePrefix,
      analyticsEnabled: analyticsEnabled,
    );
    final dimensions = _settingService.get(embeddingsDimensionsKey).value;
    await _documentService.initialise(tablePrefix, dimensions);
    await _chatService.initialise(tablePrefix, dimensions);
    _totalChats = await _chatRepository.getTotal(tablePrefix);
  }

  Future<void> deleteAllData() async {
    final clearSettings = !isKeepSettings;
    if (clearSettings) {
      await _settingService.clearData(tablePrefix);
    }
    await _documentService.clearData(tablePrefix, clearSettings: clearSettings);
    await _chatService.clearData(tablePrefix, clearSettings: clearSettings);
    unawaited(_analyticsFacade.trackDataCleared(keepSettings: isKeepSettings));
  }

  Future<void> showEmbeddingDialog(Embedding embedding) async {
    unawaited(_analyticsFacade.trackEmbeddingDialogOpened());
    await _dialogService.showCustomDialog<void, Embedding>(
      variant: DialogType.embedding,
      data: embedding,
      barrierDismissible: true,
    );
  }

  Future<void> showPromptTemplateDialog() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.promptTemplate,
      title: 'Edit Prompt Template',
      description: '''
Prompt template of the LLM.
Supported variables: $contextPlaceholder and $instructionPlaceholder.''',
    );
  }

  Future<bool> showClearDataDialog() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirm,
      title: 'Clear data',
      description: '''
Data deleted permanently will not able to recover.
Are you sure you want to continue?''',
    );
    return response?.confirmed ?? false;
  }

  Future<bool> showNewChatDialog() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirm,
      title: 'New chat',
      description: '''
Starting a new chat will stop the current conversation.
Are you sure you want to proceed?''',
    );
    return response?.confirmed ?? false;
  }

  Future<void> showSystemPromptDialog() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.systemPrompt,
      title: 'Edit System Prompt',
      description: 'Custom instructions for the chatbot.',
    );
  }

  Future<void> disconnect() async {
    setBusy(true);
    await _connectionSettingService.disconnect();
    _settingService.clear();
    await _connectDatabase();
    setBusy(false);
  }
}
