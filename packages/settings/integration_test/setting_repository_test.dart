import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<SettingRepository>();

  setUpAll(() async {
    if (wasm) {
      await db.connect(surrealIndxdbEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
    } else {
      await db.connect(surrealHttpEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
      await db
          .signin({'username': surrealUsername, 'password': surrealPassword});
    }
  });

  tearDownAll(() async {
    await db.close();
  });
  tearDown(() async {
    await repository.deleteAllSettings(defaultTablePrefix);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isFalse);
    });

    test('should create schema and return true', () async {
      // Arrange
      if (!await repository.isSchemaCreated(defaultTablePrefix)) {
        await repository.createSchema(defaultTablePrefix);
      }
      // Assert
      expect(await repository.isSchemaCreated(defaultTablePrefix), isTrue);
    });
  });

  group('createSetting', () {
    test('should create setting', () async {
      // Arrange
      const setting = Setting(
        key: 'key1',
        value: 'value1',
      );

      // Act
      final result =
          await repository.createSetting(defaultTablePrefix, setting);

      // Assert
      expect(result.key, equals('key1'));
    });
  });
  group('getAllSettings', () {
    test('should return a list of settings', () async {
      // Arrange
      final settings = [
        const Setting(
          key: 'key1',
          value: 'value1',
        ).toJson(),
        const Setting(
          key: 'key2',
          value: 'value2',
        ).toJson(),
      ];
      await db.delete('${defaultTablePrefix}_${Setting.tableName}');
      await db.query(
        '''
INSERT INTO ${defaultTablePrefix}_${Setting.tableName} ${jsonEncode(settings)}''',
      );

      // Act
      final result = await repository.getAllSettings(defaultTablePrefix);

      // Assert
      expect(result, hasLength(settings.length));
    });
  });

  group('getSettingById', () {
    test('should return a setting by id', () async {
      // Arrange
      const setting = Setting(
        key: 'key1',
        value: 'value1',
      );
      final result =
          await repository.createSetting(defaultTablePrefix, setting);
      final id = result.id;

      // Act
      final getSettingById = await repository.getSettingById(id!);

      // Assert
      expect(getSettingById?.id, equals(id));
    });

    test('should not found', () async {
      // Arrange
      const id = 'Setting:1';

      // Act & Assert
      expect(await repository.getSettingById(id), isNull);
    });
  });

  group('getSettingByKey', () {
    test('should return a setting by key', () async {
      // Arrange
      const setting = Setting(
        key: 'key1',
        value: 'value1',
      );
      final result =
          await repository.createSetting(defaultTablePrefix, setting);

      // Act
      final getSettingByKey =
          await repository.getSettingByKey(defaultTablePrefix, result.key);

      // Assert
      expect(getSettingByKey?.key, equals(result.key));
    });

    test('should not found', () async {
      // Arrange
      const key = 'key3';

      // Act & Assert
      expect(await repository.getSettingByKey(defaultTablePrefix, key), isNull);
    });
  });

  group('updateSetting', () {
    test('should update setting', () async {
      // Arrange
      const setting = Setting(
        key: 'key1',
        value: 'value1',
      );
      final created =
          await repository.createSetting(defaultTablePrefix, setting);

      // Act
      const value1 = 'value one';
      final updated =
          await repository.updateSetting(created.copyWith(value: value1));

      // Assert
      expect(updated?.value, equals(value1));
    });

    test('should be null when the update setting is not found', () async {
      // Arrange
      const setting = Setting(
        id: '${defaultTablePrefix}_${Setting.tableName}:1',
        key: 'key3',
        value: 'value3',
      );
      // Act & Assert
      expect(await repository.updateSetting(setting), isNull);
    });
  });

  group('deleteSetting', () {
    test('should delete setting', () async {
      // Arrange
      const setting = Setting(
        key: 'key1',
        value: 'value1',
      );
      final created =
          await repository.createSetting(defaultTablePrefix, setting);

      // Act
      final result = await repository.deleteSetting(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete setting is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Setting.tableName}:1';

      // Act & Assert
      expect(await repository.deleteSetting(id), isNull);
    });
  });
}
