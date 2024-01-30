import 'package:chat/chat.dart';
import 'package:document/document.dart';
import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/common/app_strings.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({this.tablePrefix = defaultTablePrefix});
  final String tablePrefix;

  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _settingService = locator<SettingService>();
  final _documentService = locator<DocumentService>();
  final _chatRepository = locator<ChatRepository>();
  final _chatService = locator<ChatService>();
  int get totalChats => _totalChats;
  late int _totalChats;
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

  String getSettingValue(String key, {Type? type}) {
    final setting = _settingService.get(key, type: type);
    return setting.value;
  }

  Future<void> initialise() async {
    await _settingService.initialise(tablePrefix);
    _totalChats = await _chatRepository.getTotal(tablePrefix);
  }

  Future<void> deleteAllData() async {
    if (!isKeepSettings) {
      await _settingService.clearData(tablePrefix);
    }
    await _documentService.clearData(tablePrefix);
    await _chatService.clearData(tablePrefix);
  }
}
