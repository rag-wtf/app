import 'package:database/src/app/app.locator.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final repository = locator<ConnectionSettingRepository>();
  final storage = locator<FlutterSecureStorage>();

  tearDown(() async {
    await repository.deleteAllConnectionSettings();
  });

  group('createConnectionKey', () {
    test('should return connectionKey', () async {
      // Assert
      expect(
        await repository.createConnectionKey(),
        '${ConnectionSetting.connectionKey}1',
      );
      expect(
        await storage.read(
          key: ConnectionSettingRepository.connectionCounterKey,
        ),
        '1',
      );
      expect(
        await repository.createConnectionKey(),
        '${ConnectionSetting.connectionKey}2',
      );
      expect(
        await storage.read(
          key: ConnectionSettingRepository.connectionCounterKey,
        ),
        '2',
      );
      expect(await repository.getAllConnectionKeys(), hasLength(2));
    });
  });

  group('deleteConnectionKey', () {
    test('should delete a connectionKey', () async {
      // Arrange
      await repository.createConnectionKey();
      await repository.createConnectionKey();
      await repository.createConnectionKey();
      final expected = [
        '${ConnectionSetting.connectionKey}1',
        '${ConnectionSetting.connectionKey}3',
      ];

      // Act & Assert
      await repository
          .deleteConnectionKey('${ConnectionSetting.connectionKey}2');
      expect(await repository.getAllConnectionKeys(), equals(expected));

      await repository
          .deleteConnectionKey('${ConnectionSetting.connectionKey}1');
      expect(
        await repository.getAllConnectionKeys(),
        equals(['${ConnectionSetting.connectionKey}3']),
      );
    });

    test('Value of connectionKeysKey should be null', () async {
      // Arrange
      await repository.createConnectionKey();

      // Act
      await repository
          .deleteConnectionKey('${ConnectionSetting.connectionKey}1');

      // Assert
      expect(
        await storage.read(
          key: ConnectionSettingRepository.connectionKeysKey,
        ),
        isNull,
      );
    });
  });

  group('createConnectionSetting', () {
    test('should create connectionSetting', () async {
      // Arrange
      const connectionName = 'Connection 1';
      final connectionKey = await repository.createConnectionKey();

      // Act
      final connectionSetting = await repository.createConnectionSetting(
        connectionKey,
        ConnectionSetting.nameKey,
        connectionName,
      );

      // Assert
      expect(
        connectionSetting.key,
        equals('${connectionKey}_${ConnectionSetting.nameKey}'),
      );
      expect(connectionSetting.value, equals(connectionName));
    });
  });

  group('getAllConnectionNames', () {
    test('should get all connection names', () async {
      // Arrange
      const connectionName1 = 'Connection 1';
      final connectionKey1 = await repository.createConnectionKey();
      const connectionName2 = 'Connection 2';
      final connectionKey2 = await repository.createConnectionKey();

      // Act
      await repository.createConnectionSetting(
        connectionKey1,
        ConnectionSetting.nameKey,
        connectionName1,
      );
      await repository.createConnectionSetting(
        connectionKey2,
        ConnectionSetting.nameKey,
        connectionName2,
      );
      final connectionSettingNames = await repository.getAllConnectionNames();

      // Assert
      expect(
        connectionSettingNames[0].key,
        equals('${connectionKey1}_${ConnectionSetting.nameKey}'),
      );
      expect(connectionSettingNames[0].value, equals(connectionName1));
      expect(
        connectionSettingNames[1].key,
        equals('${connectionKey2}_${ConnectionSetting.nameKey}'),
      );
      expect(connectionSettingNames[1].value, equals(connectionName2));
    });
  });

  Future<Map<String, String>> createConnectionSettings(
    String connectionKey,
  ) async {
    const name = 'Connection 1';
    const protocol = 'https';
    const addressPort = 'localhost:8000';
    const namespace = 'test';
    const database = 'test';
    const username = 'root';
    const password = 'rootPass';
    final expected = {
      '${connectionKey}_${ConnectionSetting.nameKey}': name,
      '${connectionKey}_${ConnectionSetting.protocolKey}': protocol,
      '${connectionKey}_${ConnectionSetting.addressPortKey}': addressPort,
      '${connectionKey}_${ConnectionSetting.namespaceKey}': namespace,
      '${connectionKey}_${ConnectionSetting.databaseKey}': database,
      '${connectionKey}_${ConnectionSetting.usernameKey}': username,
      '${connectionKey}_${ConnectionSetting.passwordKey}': password,
    };

    // Act
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.nameKey,
      name,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.protocolKey,
      protocol,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.addressPortKey,
      addressPort,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.namespaceKey,
      namespace,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.databaseKey,
      database,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.usernameKey,
      username,
    );
    await repository.createConnectionSetting(
      connectionKey,
      ConnectionSetting.passwordKey,
      password,
    );
    return expected;
  }

  group('getAllConnectionSettings', () {
    test('should return a map of connection settings', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      final expected = await createConnectionSettings(connectionKey);

      // Act
      final result = await repository.getAllConnectionSettings(connectionKey);

      // Assert
      expect(result, equals(expected));
    });
  });

  group('getConnectionSetting', () {
    test('should return a connection setting by key', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      const key = ConnectionSetting.nameKey;
      const value = 'name1';

      final created = await repository.createConnectionSetting(
        connectionKey,
        key,
        value,
      );

      // Act
      final connectionSetting =
          await repository.getConnectionSetting(connectionKey, key);

      // Assert
      expect(created.value, equals(value));
      expect(connectionSetting?.value, equals(value));
    });

    test('should not found', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      const key = ConnectionSetting.nameKey;

      // Act & Assert
      expect(await repository.getConnectionSetting(connectionKey, key), isNull);
    });
  });

  group('updateConnectionSetting', () {
    test('should update connection setting', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      const key = ConnectionSetting.nameKey;
      const value = 'name1';

      await repository.createConnectionSetting(
        connectionKey,
        key,
        value,
      );

      // Act
      const name1 = 'name one';
      final updated = await repository.updateConnectionSetting(
        connectionKey,
        key,
        name1,
      );

      // Assert
      expect(updated?.value, equals(name1));
    });

    test('should be null when the update connection setting is not found',
        () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      const key = ConnectionSetting.nameKey;
      // Act & Assert
      expect(
        await repository.updateConnectionSetting(
          connectionKey,
          key,
          'xyz',
        ),
        isNull,
      );
    });
  });

  group('deleteConnectionSetting', () {
    test('should delete connection setting', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      const key = ConnectionSetting.nameKey;
      const value = 'name1';

      await repository.createConnectionSetting(
        connectionKey,
        key,
        value,
      );

      // Act
      await repository.deleteConnectionSetting(
        connectionKey,
        key,
      );

      // Assert
      expect(await repository.getConnectionSetting(connectionKey, key), isNull);
    });
  });

  group('deleteConnectionSettings', () {
    test('should delete connection settings by connection key', () async {
      // Arrange
      final connectionKey = await repository.createConnectionKey();
      final expected = await createConnectionSettings(connectionKey);

      // Act
      final result = await repository.getAllConnectionSettings(connectionKey);

      // Assert
      expect(result, equals(expected));

      // Act
      await repository.deleteConnectionSettings(connectionKey);

      // Assert
      expect(
        () async {
          // throw an ArgumentError as the connectionKey is deleted
          await repository.getAllConnectionSettings(connectionKey);
        },
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
