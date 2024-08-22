import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:stacked/stacked.dart';
import 'package:ulid/ulid.dart';

class SettingService with ListenableServiceMixin {
  SettingService() {
    listenToReactiveValues([_settings]);
  }
  final Map<String, Setting> _settings = {};
  final Map<String, String> _enviromentVariables = {};
  final _settingRepository = locator<SettingRepository>();
  void Function()? clearFormValuesFunction;
  final _log = getLogger('SettingService');

  Setting get(String key) {
    Setting setting;

    if (_settings.containsKey(key)) {
      setting = _settings[key]!;
    } else {
      setting = _getDefaultSetting(key);
    }
    _log.d(setting.toString());
    return setting;
  }

  Setting _getDefaultSetting(String key) {
    final value = _enviromentVariables[key];
    return Setting(
      key: key,
      value: value != null && value.isNotEmpty ? value : undefined,
    );
  }

  void _initialiseEnvironmentVariables() {
    _enviromentVariables[splitApiUrlKey] =
        const String.fromEnvironment(splitApiUrlKey);
    _enviromentVariables[chunkSizeKey] =
        const String.fromEnvironment(chunkSizeKey);
    _enviromentVariables[chunkOverlapKey] =
        const String.fromEnvironment(chunkOverlapKey);
    _enviromentVariables[embeddingsModelKey] =
        const String.fromEnvironment(embeddingsModelKey);
    _enviromentVariables[embeddingsApiUrlKey] =
        const String.fromEnvironment(embeddingsApiUrlKey);
    _enviromentVariables[embeddingsApiKey] =
        const String.fromEnvironment(embeddingsApiKey);
    _enviromentVariables[embeddingsDimensionsKey] =
        const String.fromEnvironment(embeddingsDimensionsKey);
    _enviromentVariables[embeddingsApiBatchSizeKey] =
        const String.fromEnvironment(embeddingsApiBatchSizeKey);
    _enviromentVariables[embeddingsCompressedKey] =
        const String.fromEnvironment(embeddingsCompressedKey);
    _enviromentVariables[searchTypeKey] =
        const String.fromEnvironment(searchTypeKey);
    _enviromentVariables[searchIndexKey] =
        const String.fromEnvironment(searchIndexKey);
    _enviromentVariables[searchThresholdKey] =
        const String.fromEnvironment(searchThresholdKey);
    _enviromentVariables[retrieveTopNResultsKey] =
        const String.fromEnvironment(retrieveTopNResultsKey);
    _enviromentVariables[generationModelKey] =
        const String.fromEnvironment(generationModelKey);
    _enviromentVariables[generationApiUrlKey] =
        const String.fromEnvironment(generationApiUrlKey);
    _enviromentVariables[generationApiKey] =
        const String.fromEnvironment(generationApiKey);
    _enviromentVariables[systemPromptKey] =
        const String.fromEnvironment(systemPromptKey);
    _enviromentVariables[promptTemplateKey] =
        const String.fromEnvironment(promptTemplateKey);
    _enviromentVariables[temperatureKey] =
        const String.fromEnvironment(temperatureKey);
    _enviromentVariables[topPKey] = const String.fromEnvironment(topPKey);
    _enviromentVariables[repetitionPenaltyKey] =
        const String.fromEnvironment(repetitionPenaltyKey);
    _enviromentVariables[maxTokensKey] =
        const String.fromEnvironment(maxTokensKey);
    _enviromentVariables[stopKey] = const String.fromEnvironment(stopKey);
    _enviromentVariables[streamKey] = const String.fromEnvironment(streamKey);
  }

  Future<void> initialise(String tablePrefix) async {
    if (_settings.isEmpty) {
      _initialiseEnvironmentVariables();
      final isSchemaCreated =
          await _settingRepository.isSchemaCreated(tablePrefix);
      _log.d('isSchemaCreated $isSchemaCreated');

      if (!isSchemaCreated) {
        await _settingRepository.createSchema(tablePrefix);
      }

      // create user id if not found.
      if (await _settingRepository.getSettingByKey(
            tablePrefix,
            userIdKey,
          ) ==
          null) {
        final userId = Setting(
          key: userIdKey,
          value: Ulid().toString(),
        );
        await _settingRepository.createSetting(tablePrefix, userId);
      }
      final settings = await _settingRepository.getAllSettings(tablePrefix);
      if (settings.isNotEmpty) {
        for (final setting in settings) {
          _settings[setting.key] = setting;
        }
      }
    }
  }

  Future<void> clearData(String tablePrefix) async {
    await _settingRepository.deleteAllSettings(tablePrefix);
    await _settingRepository.createSetting(
      tablePrefix,
      _settings[userIdKey]!,
    ); // add back the userId
    _settings.clear();
    await initialise(tablePrefix);
    clearFormValuesFunction?.call();
    notifyListeners();
  }

  Future<void> set(String tablePrefix, String key, String value) async {
    final newValue = value.trim();
    if (_settings.containsKey(key)) {
      final setting = _settings[key];
      if (newValue.isNotEmpty) {
        if (setting!.value != newValue) {
          final updatedSetting = await _settingRepository.updateSetting(
            setting.copyWith(
              value: newValue,
            ),
          );
          if (updatedSetting != null) {
            if (updatedSetting.value == newValue) {
              _settings[key] = updatedSetting;
              notifyListeners();
            } else {
              throw Exception('Unable to update setting of "$key"!');
            }
          } else {
            throw Exception('Setting of key "$key" not found!');
          }
        }
      } else {
        _settings.remove(key);
        final result = await _settingRepository.deleteSetting(setting!.id!);
        if (result != null) {
          notifyListeners();
        } else {
          throw Exception('Unable to delete setting of "$key"!');
        }
      }
    } else if (newValue.isNotEmpty) {
      final setting =
          Setting(key: key, value: newValue, created: DateTime.now());

      final createdSetting =
          await _settingRepository.createSetting(tablePrefix, setting);
      if (createdSetting.id != null) {
        _settings[key] = createdSetting;
        notifyListeners();
      } else {
        throw Exception('Unable to create setting of "$key"!');
      }
    }
  }
}
