import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:stacked/stacked.dart';

class ConnectionSettingService with ListenableServiceMixin {
  ConnectionSettingService() {
    listenToReactiveValues([_connections]);
  }
  List<ConnectionSetting> _connections = [];
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  void Function()? clearFormValuesFunction;
  final _log = getLogger('ConnectionSettingService');

  Future<void> initialise() async {
    if (_connections.isEmpty) {
      _connections = await _connectionSettingRepository.getAllConnections();
      _log.d('_connections loaded');
    }
  }

  Future<void> clearData() async {
    await _connectionSettingRepository.deleteAllConnectionSettings();
  }
}
