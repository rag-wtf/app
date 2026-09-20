import 'package:database/src/app/app.dialogs.dart';
import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final Logger _log = getLogger('MainViewModel');
  final DialogService _dialogService = locator<DialogService>();
  final ConnectionSettingService _connectionSettingService =
      locator<ConnectionSettingService>();

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
    if (!await _connectionSettingService.autoConnect()) {
      await _dialogService.showCustomDialog(
        variant: DialogType.connection,
        title: 'Connection',
        description: 'Create database connection',
      );
    }
  }

  Future<void> disconnect() async {
    await _connectionSettingService.disconnect();
    await _dialogService.showCustomDialog(
      variant: DialogType.connection,
      title: 'Connection',
      description: 'Create database connection',
    );
  }
}
