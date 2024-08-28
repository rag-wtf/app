import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

class ConnectionSettingService {
  final _log = getLogger('ConnectionSettingService');
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _storage = locator<FlutterSecureStorage>();
  final _db = locator<Surreal>();

  Future<bool> autoConnect() async {
    var autoConnect = false;

    final autoConnectValue =
        await _storage.read(key: ConnectionSetting.autoConnectKey);

    if (autoConnectValue != null) {
      autoConnect = bool.parse(autoConnectValue);
    }
    _log.d('autoConnect $autoConnect');
    if (autoConnect) {
      final lastConnectionKey =
          await _storage.read(key: ConnectionSetting.lastConnectionKey);
      _log.d('autoConnectionKey $lastConnectionKey');
      if (lastConnectionKey != null &&
          await _connectionSettingRepository
              .isValidConnectionKey(lastConnectionKey)) {
        final connectionSettings = await _connectionSettingRepository
            .getAllConnectionSettings(lastConnectionKey);
        final protocol = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.protocolKey}']!;
        final addressPort = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.addressPortKey}']!;
        final namespace = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.namespaceKey}']!;
        final database = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.databaseKey}']!;
        final username = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.usernameKey}']!;
        final password = connectionSettings[
            '${lastConnectionKey}_${ConnectionSetting.passwordKey}']!;
        try {
          await connect(
            protocol,
            addressPort,
            namespace,
            database,
            username,
            password,
          );
        } catch (_) {
          autoConnect = false;
        }
      } else {
        autoConnect = false;
      }
    }

    return autoConnect;
  }

  Future<void> connect(
    String protocol,
    String addressPort,
    String namespace,
    String database,
    String username,
    String password,
  ) async {
    _log
      ..d('Protocol: $protocol')
      ..d('Address & Port: $addressPort')
      ..d('Namespace: $namespace')
      ..d('Database: $database')
      ..d('Username: $username');
    try {
      await _db.connect('$protocol://$addressPort');
      await _db.use(
        namespace: namespace,
        database: database,
      );
      if (username.isNotEmpty) {
        await _db.signin(
          {'username': username, 'password': password},
        );
      }
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

  Future<void> disconnect() async {
    await _db.close();
    await _storage.delete(key: ConnectionSetting.autoConnectKey);
  }

  Future<String?> getCurrentConnectionName() async {
    String? name;
    final lastConnectionKey =
        await _storage.read(key: ConnectionSetting.lastConnectionKey);
    if (lastConnectionKey != null) {
      final connectionSetting = await _connectionSettingRepository
          .getConnectionSetting(lastConnectionKey, ConnectionSetting.nameKey);
      name = connectionSetting?.value;
    }
    _log.d('lastConnectionKey $lastConnectionKey, name $name');
    return name;
  }

  Future<bool> isReady() async {
    try {
      return (await _db.version()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
