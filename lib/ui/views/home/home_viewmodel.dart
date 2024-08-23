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
  final _chatService = locator<ChatService>();
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
  )? get redefineEmbeddingIndexFunction =>
      _embeddingRepository.redefineEmbeddingIndex;

  Future<void> initialise() async {
    setBusy(true);
    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    await connectDatabase();
    await _settingService.initialise(tablePrefix);
    final dimensions = _settingService.get(embeddingsDimensionsKey).value;
    await _documentService.initialise(tablePrefix, dimensions);
    await _chatService.initialise(tablePrefix);
    _totalChats = await _chatRepository.getTotal(tablePrefix);
    setBusy(false);
  }

  Future<void> connectDatabase() async {
    var confirmed = false;
    if (!await _connectionSettingService.autoConnect()) {
      while (!confirmed) {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.connection,
          title: 'Connection',
          description: 'Create database connection',
        );

        confirmed = response?.confirmed ?? false;
      }
    }
  }

  Future<void> deleteAllData() async {
    if (!isKeepSettings) {
      await _settingService.clearData(tablePrefix);
    }
    await _documentService.clearData(tablePrefix);
    await _chatService.clearData(tablePrefix);
  }

  Future<void> showEmbeddingDialog(Embedding embedding) async {
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
      description: 'Prompt template for the LLM.',
    );
  }

  Future<void> showSystemPromptDialog() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.systemPrompt,
      title: 'Edit System Prompt',
      description: 'Custom instructions for the chatbot.',
    );
  }

  Future<void> disconnect() async {
    await _connectionSettingService.disconnect();
    await connectDatabase();
  }
}
