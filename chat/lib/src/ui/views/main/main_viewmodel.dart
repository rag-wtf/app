import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final _settingService = locator<SettingService>();
  final _log = getLogger('MainViewModel');

  Future<void> initialise() async {
    _log.d('init() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
  }
}
