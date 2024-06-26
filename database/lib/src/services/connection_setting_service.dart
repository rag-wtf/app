import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_model.dart';
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
        await _storage.read(key: ConnectionDialogModel.autoConnectKey);

    if (autoConnectValue != null) {
      autoConnect = bool.parse(autoConnectValue);
    }
    _log.d('autoConnect $autoConnect');
    if (autoConnect) {
      final autoConnectionKey =
          await _storage.read(key: ConnectionDialogModel.autoConnectionKey);
      _log.d('autoConnectionKey $autoConnectionKey');
      if (autoConnectionKey != null &&
          await _connectionSettingRepository
              .isValidConnectionKey(autoConnectionKey)) {
        final connectionSettings = await _connectionSettingRepository
            .getAllConnectionSettings(autoConnectionKey);
        final protocol = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.protocolKey}']!;
        final addressPort = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.addressPortKey}']!;
        final namespace = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.namespaceKey}']!;
        final database = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.databaseKey}']!;
        final username = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.usernameKey}']!;
        final password = connectionSettings[
            '${autoConnectionKey}_${ConnectionSetting.passwordKey}']!;
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
    try {
      await _db.connect('$protocol://$addressPort');
      await _db.use(
        namespace: namespace,
        database: database,
      );
      await _db.signin(
        {'username': username, 'password': password},
      );
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
}
