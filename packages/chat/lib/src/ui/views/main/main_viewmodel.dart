import 'package:chat/src/app/app.dialogs.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:database/database.dart';
import 'package:document/document.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix, {required this.inPackage});
  final String tablePrefix;
  final bool inPackage;
  final _dialogService = locator<DialogService>();
  final _connectionSettingService = locator<ConnectionSettingService>();
  final _settingService = locator<SettingService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('MainViewModel');

  Future<void> initialise() async {
    _log.d('init() tablePrefix: $tablePrefix');
    if (inPackage) {
      await connectDatabase();
      await _settingService.initialise(tablePrefix);
      await _chatService.initialise(tablePrefix, defaultEmbeddingsDimensions);
    }
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

  Future<void> showEmbeddingDialog(Embedding embedding) async {
    await _dialogService.showCustomDialog<void, Embedding>(
      variant: DialogType.embedding,
      data: embedding,
    );
  }

  Future<bool> showNewChatDialog() async {
    return false;
  }
}
