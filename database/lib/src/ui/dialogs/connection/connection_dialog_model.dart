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

  final _log = getLogger('ConnectionDialogModel');
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _db = locator<Surreal>();
  String protocol = 'ws';
  late List<ConnectionSetting> connectionNames;
  bool autoConnect = true;

  Future<void> initialise() async {
    _log.d('initialise()');
    connectionNames =
        await _connectionSettingRepository.getAllConnectionNames();
  }

  Future<bool> connectAndSave() async {
    return runErrorFuture(connect(),
        key: connectErrorKey, throwException: true);
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
      await createConnectionSettings(protocol, addressPort);
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

  Future<void> createConnectionSettings(
    String protocol,
    String addressPort,
  ) async {
    final connectionKey =
        await _connectionSettingRepository.createConnectionKey();
    // Act
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
}
