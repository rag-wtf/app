import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stacked/stacked.dart';

class ConnectionDialogModel extends FormViewModel {
  static const _rpcUri = '/rpc';
  static const connectErrorKey = 'connection-dialog-connect';
  static const newConnectionKey = 'new';
  static const newConnectionName = '[New connection]';

  final _log = getLogger('ConnectionDialogModel');
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _connectionSettingService = locator<ConnectionSettingService>();
  final _storage = locator<FlutterSecureStorage>();
  String connectionKeySelected = newConnectionKey;
  String _protocol = 'ws';
  late List<ConnectionSetting> connectionNames;
  bool _autoConnect = true;

  bool get autoConnect => _autoConnect;

  set autoConnect(bool value) {
    if (_autoConnect != value) {
      _autoConnect = value;
      notifyListeners();
    }
  }

  String get protocol => _protocol;

  set protocol(String value) {
    if (_protocol != value) {
      _protocol = value;
      notifyListeners();
    }
  }

  Future<void> initialise() async {
    _log.d('initialise()');
    clearForm();
    connectionKeySelected = newConnectionKey;
    connectionNames =
        await _connectionSettingRepository.getAllConnectionNames();
    connectionNames.insert(
      0,
      const ConnectionSetting(
        key: newConnectionKey,
        value: newConnectionName,
      ),
    );
  }

  Future<void> onConnectionSelected(String connectionKey) async {
    _log.d('connectionKey $connectionKey');
    connectionKeySelected = connectionKey;
    if (connectionKey == newConnectionKey) {
      clearForm();
    } else {
      final connectionSettings = await _connectionSettingRepository
          .getAllConnectionSettings(connectionKey);
      if (connectionSettings.isNotEmpty) {
        nameValue =
            connectionSettings['${connectionKey}_${ConnectionSetting.nameKey}'];
        _protocol = connectionSettings[
            '${connectionKey}_${ConnectionSetting.protocolKey}']!;
        addressPortValue = connectionSettings[
            '${connectionKey}_${ConnectionSetting.addressPortKey}'];
        namespaceValue = connectionSettings[
            '${connectionKey}_${ConnectionSetting.namespaceKey}'];
        databaseValue = connectionSettings[
            '${connectionKey}_${ConnectionSetting.databaseKey}'];
        usernameValue = connectionSettings[
            '${connectionKey}_${ConnectionSetting.usernameKey}'];
        passwordValue = connectionSettings[
            '${connectionKey}_${ConnectionSetting.passwordKey}'];
      }
    }
  }

  Future<bool> connectAndSave() async {
    var addressPort = addressPortValue!;
    if (_protocol != 'mem' &&
        protocol != 'indxdb' &&
        !addressPort.endsWith(_rpcUri)) {
      addressPort += _rpcUri;
    }
    await runErrorFuture(
      _connectionSettingService.connect(
        _protocol,
        addressPort,
        namespaceValue!,
        databaseValue!,
        usernameValue!,
        passwordValue!,
      ),
      key: connectErrorKey,
      throwException: true,
    );
    await _saveConnectionSettings(_protocol, addressPort);
    await _storage.write(
      key: ConnectionSetting.autoConnectKey,
      value: autoConnect.toString(),
    );
    return true;
  }

  Future<void> _saveConnectionSettings(
    String protocol,
    String addressPort,
  ) async {
    final connectionKey = connectionKeySelected == newConnectionKey
        ? await _connectionSettingRepository.createConnectionKey()
        : connectionKeySelected;
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.nameKey,
      nameValue!,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.protocolKey,
      protocol,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.addressPortKey,
      addressPort,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.namespaceKey,
      namespaceValue!,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.databaseKey,
      databaseValue!,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.usernameKey,
      usernameValue!,
    );
    await _connectionSettingRepository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.passwordKey,
      passwordValue!,
    );

    await _storage.write(
      key: ConnectionSetting.lastConnectionKey,
      value: connectionKey,
    );
  }

  Future<void> delete() async {
    if (connectionKeySelected != newConnectionKey) {
      await _connectionSettingRepository
          .deleteConnectionSettings(connectionKeySelected);
      connectionNames.removeWhere(
        (connectionSetting) =>
            connectionSetting.key.startsWith(connectionKeySelected),
      );
      connectionKeySelected = newConnectionKey;

      clearForm();
    }
  }
}
