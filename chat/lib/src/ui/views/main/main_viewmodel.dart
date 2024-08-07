import 'package:chat/src/app/app.dialogs.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:document/document.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;
  final _dialogService = locator<DialogService>();
  final _settingService = locator<SettingService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('MainViewModel');

  Future<void> initialise() async {
    _log.d('init() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    await _chatService.initialise(tablePrefix);
  }

  Future<void> showEmbeddingDialog(Embedding embedding) async {
    await _dialogService.showCustomDialog<void, Embedding>(
      variant: DialogType.embedding,
      data: embedding,
    );
  }
}
