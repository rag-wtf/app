import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:stacked_package_template/src/app/app.locator.dart';
import 'package:stacked_package_template/src/services/model.dart';
import 'package:stacked_package_template/src/services/model_repository.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final repository = locator<ModelRepository>();

  setUpAll(() async {});

  tearDown(() async {
    await repository.deleteAllModels(defaultTablePrefix);
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

  group('createModel', () {
    test('should create model', () async {
      // Arrange
      final model = Model(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      // Act
      final result = await repository.createModel(defaultTablePrefix, model);

      // Assert
      expect(result.name, equals('name1'));
    });
  });
  group('getAllModels', () {
    test('should return a list of models', () async {
      // Arrange
      final models = [
        Model(
          name: 'name1',
          created: DateTime.now(),
          updated: DateTime.now(),
        ).toJson(),
        Model(
          name: 'name2',
          created: DateTime.now(),
          updated: DateTime.now(),
        ).toJson(),
      ];
      await db.delete('${defaultTablePrefix}_${Model.tableName}');
      await db.query(
        'INSERT INTO ${defaultTablePrefix}_${Model.tableName} ${jsonEncode(models)}',
      );

      // Act
      final result = await repository.getAllModels(defaultTablePrefix);

      // Assert
      expect(result, hasLength(models.length));
    });
  });

  group('getModelById', () {
    test('should return a model by id', () async {
      // Arrange
      final model = Model(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final result = await repository.createModel(defaultTablePrefix, model);
      final id = result.id!;

      // Act
      final getModelById = await repository.getModelById(id);

      // Assert
      expect(getModelById?.id, equals(id));
    });

    test('should not found', () async {
      // Arrange
      const id = 'Model:1';

      // Act & Assert
      expect(await repository.getModelById(id), isNull);
    });
  });

  group('updateModel', () {
    test('should update model', () async {
      // Arrange
      final model = Model(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final created = await repository.createModel(defaultTablePrefix, model);

      // Act
      const name1 = 'name one';
      final updated =
          await repository.updateModel(created.copyWith(name: name1));

      // Assert
      expect(updated?.name, equals(name1));
    });

    test('should be null when the update model is not found', () async {
      // Arrange
      final model = Model(
        id: '${defaultTablePrefix}_${Model.tableName}:1',
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      // Act & Assert
      expect(await repository.updateModel(model), isNull);
    });
  });

  group('deleteModel', () {
    test('should delete model', () async {
      // Arrange
      final model = Model(
        name: 'name1',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      final created = await repository.createModel(defaultTablePrefix, model);

      // Act
      final result = await repository.deleteModel(created.id!);

      // Assert
      expect(result?.id, created.id);
    });

    test('should be null when the delete model is not found', () async {
      // Arrange
      const id = '${defaultTablePrefix}_${Model.tableName}:1';

      // Act & Assert
      expect(await repository.deleteModel(id), isNull);
    });
  });
}
