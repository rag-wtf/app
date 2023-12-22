import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late SettingRepository repository;
  final db = Surreal();

  setUpAll(() async {
    await db.connect('mem://');
    await db.use(ns: 'test', db: 'test');
    repository = SettingRepository(db: db);
  });

  tearDown(() async {
    await repository.deleteAllSettings(prefix);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(await repository.isSchemaCreated(prefix), isFalse);
    });

    test('should create schema and return true', () async {
      // Arrange
      if (!await repository.isSchemaCreated(prefix)) {
        await repository.createSchema(prefix);
      }
      // Assert
      expect(await repository.isSchemaCreated(prefix), isTrue);
    });
  });

  group('createSetting', () {
    test('should create setting', () async {
      // Arrange
      final setting = Setting(
        key: 'key1',
        value: 'value1',
        created: DateTime.now(),
      );

      // Act
      final result = await repository.createSetting(prefix, setting);

      // Assert
      expect(result.key, equals('key1'));
    });
  });
  group('getAllSettings', () {
    test('should return a list of settings', () async {
      // Arrange
      final settings = [
        Setting(
          key: 'key1',
          value: 'value1',
          created: DateTime.now(),
        ).toJson(),
        Setting(
          key: 'key2',
          value: 'value2',
          created: DateTime.now(),
        ).toJson(),
      ];
      await db.delete('${prefix}_${Setting.tableName}');
      await db.query(
        'INSERT INTO ${prefix}_${Setting.tableName} ${jsonEncode(settings)}',
      );

      // Act
      final result = await repository.getAllSettings(prefix);

      // Assert
      expect(result, hasLength(settings.length));
    });
  });

  group('getSettingById', () {
    test('should return a setting by id', () async {
      // Arrange
      final setting = Setting(
        key: 'key1',
        value: 'value1',
        created: DateTime.now(),
      );
      final result = await repository.createSetting(prefix, setting);
      final id = result.id!;

      // Act
      final getSettingById = await repository.getSettingById(id);

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
      final setting = Setting(
        key: 'key1',
        value: 'value1',
        created: DateTime.now(),
      );
      final result = await repository.createSetting(prefix, setting);

      // Act
      final getSettingByKey =
          await repository.getSettingByKey(prefix, result.key);

      // Assert
      expect(getSettingByKey?.key, equals(result.key));
    });

    test('should not found', () async {
      // Arrange
      const key = 'key3';

      // Act & Assert
      expect(await repository.getSettingByKey(prefix, key), isNull);
    });
  });

  group('updateSetting', () {
    test('should update setting', () async {
      // Arrange
      final setting = Setting(
        key: 'key1',
        value: 'value1',
        created: DateTime.now(),
      );
      final created = await repository.createSetting(prefix, setting);

      // Act
      const value1 = 'value one';
      final updated =
          await repository.updateSetting(created.copyWith(value: value1));

      // Assert
      expect(updated?.value, equals(value1));
    });

    test('should be null when the update setting is not found', () async {
      // Arrange
      final setting = Setting(
        id: '${prefix}_${Setting.tableName}:1',
        key: 'key3',
        value: 'value3',
        created: DateTime.now(),
      );
      // Act & Assert
      expect(await repository.updateSetting(setting), isNull);
    });
  });

  group('deleteSetting', () {
    test('should delete setting', () async {
      // Arrange
      final setting = Setting(
        key: 'key1',
        value: 'value1',
        created: DateTime.now(),
      );
      final created = await repository.createSetting(prefix, setting);

      // Act
      final result = await repository.deleteSetting(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete setting is not found', () async {
      // Arrange
      const id = '${prefix}_${Setting.tableName}:1';

      // Act & Assert
      expect(await repository.deleteSetting(id), isNull);
    });
  });
}
