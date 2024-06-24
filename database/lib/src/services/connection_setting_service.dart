import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:stacked/stacked.dart';

class ConnectionSettingService with ListenableServiceMixin {
  ConnectionSettingService() {
    listenToReactiveValues([_connectionNames]);
  }
  List<ConnectionSetting> _connectionNames = [];
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  void Function()? clearFormValuesFunction;
  final _log = getLogger('ConnectionSettingService');

  Future<void> initialise() async {
    if (_connectionNames.isEmpty) {
      _connectionNames =
          await _connectionSettingRepository.getAllConnectionNames();
      _log.d('_connections loaded');
    }
  }

  Future<void> clearData() async {
    await _connectionSettingRepository.deleteAllConnectionSettings();
  }
}
