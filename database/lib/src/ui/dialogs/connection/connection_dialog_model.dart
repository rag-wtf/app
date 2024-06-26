import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class ConnectionDialogModel extends FormViewModel {
  static const _rpcUri = '/rpc';
  static const connectErrorKey = 'connection-dialog-connect';
  static const newConnectionKey = 'new';
  static const newConnectionName = '[New connection]';

  final _log = getLogger('ConnectionDialogModel');
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _db = locator<Surreal>();
  String connectionKeySelected = newConnectionKey;
  String protocol = 'ws';
  late List<ConnectionSetting> connectionNames;
  bool autoConnect = true;

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
        protocol = connectionSettings[
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
    return runErrorFuture(connect(), key: connectErrorKey);
  }

  Future<bool> connect() async {
    _log
      ..d('Name: $nameValue')
      ..d('Protocol: $protocol')
      ..d('Address & Port: $addressPortValue')
      ..d('Namespace: $namespaceValue')
      ..d('Database: $databaseValue')
      ..d('Username: $usernameValue');

    var addressPort = addressPortValue!;
    if (!addressPort.endsWith(_rpcUri)) {
      addressPort += _rpcUri;
    }

    try {
      await _db.connect('$protocol://$addressPort');
      await _db.use(
        namespace: namespaceValue,
        database: databaseValue,
      );
      await _db.signin(
        {'username': usernameValue, 'password': passwordValue},
      );
      await saveConnectionSettings(protocol, addressPort);
      return true;
    } catch (e) {
      final error = e.toString();

      if (error.startsWith('VersionRetrievalFailure')) {
        throw Exception('Unable to connect to database!');
      } else if (error.endsWith('authentication')) {
        throw Exception('Invalid username or password!');
      } else {
        rethrow;
      }
    }
  }

  Future<void> saveConnectionSettings(
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
