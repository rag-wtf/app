import 'dart:convert';

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

  tearDownAll(() async {
    await repository.deleteAllConnectionSettings();
  });

  group('createConnectionKey', () {
    test('should return connectionKey', () async {
      // Assert
      expect(
        await repository.createConnectionKey(),
        '${ConnectionSetting.connectionKey}0',
      );
      expect(
        await storage.read(
          key: ConnectionSettingRepository.connectionKeyCounterKey,
        ),
        '0',
      );
      expect(
        await repository.createConnectionKey(),
        '${ConnectionSetting.connectionKey}1',
      );
      expect(
        await storage.read(
          key: ConnectionSettingRepository.connectionKeyCounterKey,
        ),
        '1',
      );
    });
  });

/*
  group('createConnectionSetting', () {
    test('should create connectionSetting', () async {
      // Arrange
      const connectionSetting = ConnectionSetting(
        name: 'name1',
      );

      // Act
      final result = await repository.createConnectionSetting(
          defaultTablePrefix, connectionSetting);

      // Assert
      expect(result.name, equals('name1'));
    });
  });
  group('getAllConnectionSettings', () {
    test('should return a list of connectionSettings', () async {
      // Arrange
      final connectionSettings = [
        const ConnectionSetting(
          name: 'name1',
        ).toJson(),
        const ConnectionSetting(
          name: 'name2',
        ).toJson(),
      ];
      await db.delete('${defaultTablePrefix}_${ConnectionSetting.tableName}');
      await db.query(
        '''
INSERT INTO ${defaultTablePrefix}_${ConnectionSetting.tableName} ${jsonEncode(connectionSettings)}''',
      );

      // Act
      final result =
          await repository.getAllConnectionSettings(defaultTablePrefix);

      // Assert
      expect(result, hasLength(connectionSettings.length));
    });
  });

  group('getConnectionSettingById', () {
    test('should return a connectionSetting by id', () async {
      // Arrange
      const connectionSetting = ConnectionSetting(
        name: 'name1',
      );
      final result = await repository.createConnectionSetting(
          defaultTablePrefix, connectionSetting);
      final id = result.id!;

      // Act
      final getConnectionSettingById =
          await repository.getConnectionSettingById(id);

      // Assert
      expect(getConnectionSettingById?.id, equals(id));
    });

    test('should not found', () async {
      // Arrange
      const id = 'ConnectionSetting:1';

      // Act & Assert
      expect(await repository.getConnectionSettingById(id), isNull);
    });
  });

  group('updateConnectionSetting', () {
    test('should update connectionSetting', () async {
      // Arrange
      const connectionSetting = ConnectionSetting(
        name: 'name1',
      );
      final created = await repository.createConnectionSetting(
          defaultTablePrefix, connectionSetting);

      // Act
      const name1 = 'name one';
      final updated = await repository
          .updateConnectionSetting(created.copyWith(name: name1));

      // Assert
      expect(updated?.name, equals(name1));
    });

    test('should be null when the update connectionSetting is not found',
        () async {
      // Arrange
      const connectionSetting = ConnectionSetting(
        id: '${defaultTablePrefix}_${ConnectionSetting.tableName}:1',
        name: 'name1',
      );
      // Act & Assert
      expect(
          await repository.updateConnectionSetting(connectionSetting), isNull);
    });
  });

  group('deleteConnectionSetting', () {
    test('should delete connectionSetting', () async {
      // Arrange
      const connectionSetting = ConnectionSetting(
        name: 'name1',
      );
      final created = await repository.createConnectionSetting(
          defaultTablePrefix, connectionSetting);

      // Act
      final result = await repository.deleteConnectionSetting(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete connectionSetting is not found',
        () async {
      // Arrange
      const id = '${defaultTablePrefix}_${ConnectionSetting.tableName}:1';

      // Act & Assert
      expect(await repository.deleteConnectionSetting(id), isNull);
    });
  }); */
}
