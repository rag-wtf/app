import 'package:database/src/app/app.locator.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConnectionSettingRepository {
  final _storage = locator<FlutterSecureStorage>();
  static const connectionKeysKey = 'connectionKeysKey';
  static const _valueKeys = [
    ConnectionSetting.protocolKey,
    ConnectionSetting.addressPortKey,
    ConnectionSetting.namespaceKey,
    ConnectionSetting.databaseKey,
    ConnectionSetting.usernameKey,
    ConnectionSetting.passwordKey,
  ];
  static const connectionCounterKey = 'connectionKeyCounterKey';

  Future<String> createConnectionKey() async {
    final connectionKeyCounterFromStorage =
        await _storage.read(key: connectionCounterKey);
    final connectionKeyCounter = connectionKeyCounterFromStorage != null
        ? int.parse(connectionKeyCounterFromStorage) + 1
        : 0;
    await _storage.write(
      key: connectionCounterKey,
      value: connectionKeyCounter.toString(),
    );

    final connectionKeys = await _storage.read(key: connectionKeysKey);
    final connectionKey = connectionKeys != null
        ? '$connectionKeys,${ConnectionSetting.connectionKey}$connectionKeyCounter'
        : '${ConnectionSetting.connectionKey}$connectionKeyCounter';
    await _storage.write(key: connectionKeysKey, value: connectionKey);
    return connectionKey;
  }

  Future<void> deleteConnectionKey(String connectionKey) async {
    final connectionKeys = await getAllConnectionKeys();
    if (connectionKeys.remove(connectionKey)) {
      await _storage.write(
        key: connectionKeysKey,
        value: connectionKeys.join(','),
      );
    }
  }

  Future<List<String>> getAllConnectionKeys() async {
    final connectionKeys = await _storage.read(key: connectionKeysKey);
    return connectionKeys != null ? connectionKeys.split(',') : List.empty();
  }

  Future<List<ConnectionSetting>> getAllConnections() async {
    final connectionKeys = await getAllConnectionKeys();
    final connections = <ConnectionSetting>[];

    for (final connectionKey in connectionKeys) {
      connections.add(
        ConnectionSetting(
          key: connectionKey,
          value: (await _storage.read(key: connectionKey))!,
        ),
      );
    }
    return connections;
  }

  Future<ConnectionSetting> createConnectionSetting(
    String connectionKey,
    String key,
    String value,
  ) async {
    final compositeKey = '${connectionKey}_$key';
    await _storage.write(key: compositeKey, value: value);
    return ConnectionSetting(key: compositeKey, value: value);
  }

  Future<Map<String, String?>> getAllConnectionSettings(
    String connectionKey,
  ) async {
    final connectionSettings = {
      for (final valueKey in _valueKeys)
        if (await _storage.containsKey(key: '${connectionKey}_$valueKey'))
          '${connectionKey}_$valueKey':
              await _storage.read(key: '${connectionKey}_$valueKey')
    };
    return connectionSettings;
  }

  Future<ConnectionSetting?> getConnectionSetting(
    String connectionKey,
    String key,
  ) async {
    final compositeKey = '${connectionKey}_$key';
    if (await _storage.containsKey(key: compositeKey)) {
      return ConnectionSetting(
        key: compositeKey,
        value: (await _storage.read(key: compositeKey))!,
      );
    } else {
      return null;
    }
  }

  Future<ConnectionSetting?> updateConnectionSetting(
    String connectionKey,
    String key,
    String value,
  ) async {
    final compositeKey = '${connectionKey}_$key';
    if (await _storage.containsKey(key: compositeKey)) {
      await _storage.write(key: compositeKey, value: value);
      return ConnectionSetting(
        key: compositeKey,
        value: value,
      );
    } else {
      return null;
    }
  }

  Future<void> deleteConnectionSetting(
    String connectionKey,
    String key,
  ) async {
    final compositeKey = '${connectionKey}_$key';
    await _storage.delete(key: compositeKey);
  }

  Future<void> deleteConnectionSettings(String connectionKey) async {
    for (final valueKey in _valueKeys) {
      await _storage.delete(key: '${connectionKey}_$valueKey');
    }
  }

  Future<void> deleteAllConnectionSettings() async {
    final connectionKeys = await _storage.read(key: connectionKeysKey);
    final connectionKeyList = connectionKeys!.split(',');
    for (final connectionKey in connectionKeyList) {
      await _storage.delete(key: connectionKey);
      for (final valueKey in _valueKeys) {
        await _storage.delete(key: '${connectionKey}_$valueKey');
      }
    }
    await _storage.delete(key: connectionKeysKey);
    await _storage.delete(key: connectionCounterKey);
  }
}
