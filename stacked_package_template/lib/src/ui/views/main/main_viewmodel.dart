import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_package_template/src/app/app.locator.dart';
import 'package:stacked_package_template/src/app/app.logger.dart';

class MainViewModel extends FutureViewModel<void> {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final _settingService = locator<SettingService>();
  final _log = getLogger('MainViewModel');

  @override
  Future<void> futureToRun() async {
    _log.d('futureToRun() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
  }
}
