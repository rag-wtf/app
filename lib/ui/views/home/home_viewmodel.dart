import 'package:chat/chat.dart';
import 'package:document/document.dart';
import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/common/app_strings.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends FutureViewModel<void> {
  HomeViewModel({this.tablePrefix = defaultTablePrefix});
  final String tablePrefix;

  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _settingService = locator<SettingService>();
  final _settingRepository = locator<SettingRepository>();
  final _documentRepository = locator<DocumentRepository>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _chatRepository = locator<ChatRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _chatService = locator<ChatService>();
  int get totalChats => _totalChats;
  late int _totalChats;
  bool _isSettingsDataExcludedFromDeletion = true;
  bool get isSettingsDataExcludedFromDeletion =>
      _isSettingsDataExcludedFromDeletion;
  set isSettingsDataExcludedFromDeletion(bool value) {
    _isSettingsDataExcludedFromDeletion = value;
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

  String getSettingValue(String key, {Type? type}) {
    final setting = _settingService.get(key, type: type);
    return setting.value;
  }

  @override
  Future<void> futureToRun() async {
    await _settingService.initialise(tablePrefix);
    _totalChats = await _chatRepository.getTotal(tablePrefix);
  }

  Future<void> deleteAllData() async {
    if (!isSettingsDataExcludedFromDeletion) {
      await _settingRepository.deleteAllSettings(tablePrefix);
      await _settingService.initialise(tablePrefix);
    }
    await _documentRepository.deleteAllDocuments(tablePrefix);
    await _embeddingRepository.deleteAllEmbeddings(tablePrefix);
    await _chatRepository.deleteAllChats(tablePrefix);
    await _messageRepository.deleteAllMessages(tablePrefix);
    _chatService.initialise();

    notifyListeners();
  }
}
