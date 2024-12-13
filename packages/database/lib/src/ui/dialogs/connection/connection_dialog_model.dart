import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/constants.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stacked/stacked.dart';

class ConnectionDialogModel extends FormViewModel {
  static const _rpcUri = '/rpc';
  static const connectErrorKey = 'connection-dialog-connect';
  static const newConnectionKey = 'new';
  static const newConnectionName = '[New connection]';

  final _log = getLogger('ConnectionDialogModel');
  final analyticsFacade = locator<AnalyticsFacade>();
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _connectionSettingService = locator<ConnectionSettingService>();
  final _storage = locator<FlutterSecureStorage>();
  String connectionKeySelected = newConnectionKey;
  String _protocol = 'ws';
  late List<ConnectionSetting> connectionNames;
  bool _autoConnect = true;
  bool _analyticsEnabled = true;

  bool get autoConnect => _autoConnect;
  bool get analyticsEnabled => _analyticsEnabled;

  set autoConnect(bool value) {
    if (_autoConnect != value) {
      _autoConnect = value;
      notifyListeners();
    }
  }

  set analyticsEnabled(bool value) {
    if (_analyticsEnabled != value) {
      _analyticsEnabled = value;
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
    setBusy(true);
    await _clearForm();
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
    setBusy(false);
  }

  Future<void> initialiseName() async {
    final counter = await _connectionSettingRepository.getConnectionCounter();
    nameValue = '$defaultName $counter';
  }

  Future<void> _clearForm() async {
    clearForm();
    await initialiseName();
  }

  Future<void> onConnectionSelected(String connectionKey) async {
    _log.d('connectionKey $connectionKey');
    connectionKeySelected = connectionKey;
    if (connectionKey == newConnectionKey) {
      await _clearForm();
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

  bool validate() {
    validateForm();
    if (hasAnyValidationMessage) {
      return false;
    }
    var validationMessage =
        ConnectionDialogValidators.validateNamespaceOrDatabaseValue(
      namespaceValue,
      databaseValue,
    );
    if (validationMessage != null && validationMessage.isNotEmpty) {
      fieldsValidationMessages[NamespaceValueKey] = validationMessage;
      notifyListeners();
      return false;
    }
    switch (_protocol) {
      case 'ws':
      case 'wss':
      case 'http':
      case 'https':
        validationMessage = ConnectionDialogValidators.validateAddressPort(
          _protocol,
          addressPortValue,
        );
        if (validationMessage != null && validationMessage.isNotEmpty) {
          fieldsValidationMessages[AddressPortValueKey] = validationMessage;
          notifyListeners();
          return false;
        }
        if (validationMessage != null && validationMessage.isNotEmpty) {
          fieldsValidationMessages[NamespaceValueKey] = validationMessage;
          notifyListeners();
          return false;
        }
        validationMessage = ConnectionDialogValidators.validateUsername(
          usernameValue,
        );
        if (validationMessage != null && validationMessage.isNotEmpty) {
          fieldsValidationMessages[UsernameValueKey] = validationMessage;
          notifyListeners();
          return false;
        }
        validationMessage = ConnectionDialogValidators.validatePassword(
          passwordValue,
        );
        if (validationMessage != null && validationMessage.isNotEmpty) {
          fieldsValidationMessages[PasswordValueKey] = validationMessage;
          notifyListeners();
          return false;
        }
        return true;
      case 'indxdb':
        validationMessage =
            ConnectionDialogValidators.validateDatabaseName(addressPortValue);
        if (validationMessage != null && validationMessage.isNotEmpty) {
          fieldsValidationMessages[AddressPortValueKey] = validationMessage;
          notifyListeners();
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<bool> connectAndSave() async {
    var addressPort = addressPortValue;
    if (_protocol != 'mem' &&
        protocol != 'indxdb' &&
        !addressPort!.endsWith(_rpcUri)) {
      addressPort += _rpcUri;
    }
    await runErrorFuture(
      _connectionSettingService.connect(
        _protocol,
        addressPort!,
        namespaceValue!,
        databaseValue,
        usernameValue,
        passwordValue,
      ),
      key: connectErrorKey,
      throwException: true,
    );
    await _saveConnectionSettings(_protocol, addressPort);
    await _storage.write(
      key: ConnectionSetting.autoConnectKey,
      value: autoConnect.toString(),
    );
    if (_analyticsEnabled) {
      unawaited(
        analyticsFacade.trackDatabaseConnected(
          _protocol,
          autoConnect: _autoConnect,
        ),
      );
    }
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
    if (autoConnect && passwordValue != null) {
      await _connectionSettingRepository.createConnectionSetting(
        connectionKey,
        ConnectionSetting.passwordKey,
        passwordValue!,
      );
    }

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

      await _clearForm();
    }
  }
}
