import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class MainViewModel extends FutureViewModel<void> {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;
  late ChatViewModel _chatViewModel;
  ChatViewModel get chatViewModel => _chatViewModel;

  final _settingService = locator<SettingService>();
  final _log = getLogger('MainViewModel');

  @override
  Future<void> futureToRun() async {
    _log.d('futureToRun() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    _chatViewModel = ChatViewModel(tablePrefix);
  }
}
