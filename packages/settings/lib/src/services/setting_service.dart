import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
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
  late Map<String, LlmProvider> _llmProviders;
  Map<String, LlmProvider> get llmProviders => _llmProviders;

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
      value: value!,
    );
  }

  void _initialiseEnvironmentVariables() {
    if (_enviromentVariables.isEmpty) {
      _enviromentVariables[llmProviderKey] =
          const String.fromEnvironment(llmProviderKey);
      _enviromentVariables[splitApiUrlKey] =
          const String.fromEnvironment(splitApiUrlKey);
      _enviromentVariables[chunkSizeKey] = const String.fromEnvironment(
        chunkSizeKey,
        defaultValue: defaultChunkSize,
      );
      _enviromentVariables[chunkOverlapKey] = const String.fromEnvironment(
        chunkOverlapKey,
        defaultValue: defaultChunkOverlap,
      );
      _enviromentVariables[embeddingsModelKey] =
          const String.fromEnvironment(embeddingsModelKey);
      _enviromentVariables[embeddingsModelContextLengthKey] =
          const String.fromEnvironment(
        embeddingsModelContextLengthKey,
        defaultValue: defaultEmbeddingsModelContextLength,
      );    
      _enviromentVariables[embeddingsApiUrlKey] =
          const String.fromEnvironment(embeddingsApiUrlKey);
      _enviromentVariables[embeddingsApiKey] =
          const String.fromEnvironment(embeddingsApiKey);
      _enviromentVariables[embeddingsDimensionsKey] = 
          const String.fromEnvironment(
            embeddingsDimensionsKey, 
            defaultValue: defaultEmbeddingsDimensions,
          );
      _enviromentVariables[embeddingsDimensionsEnabledKey] = 
          const String.fromEnvironment(
            embeddingsDimensionsEnabledKey, 
            defaultValue: defaultEmbeddingsDimensionsEnabled,
          );          
      _enviromentVariables[embeddingsApiBatchSizeKey] =
          const String.fromEnvironment(
        embeddingsApiBatchSizeKey,
        defaultValue: defaultEmbeddingsApiBatchSize,
      );
      _enviromentVariables[embeddingsDatabaseBatchSizeKey] =
          const String.fromEnvironment(
        embeddingsDatabaseBatchSizeKey,
        defaultValue: defaultEmbeddingsDatabaseBatchSize,
      );
      _enviromentVariables[embeddingsCompressedKey] = 
          const String.fromEnvironment(
            embeddingsCompressedKey, 
            defaultValue: defaultEmbeddingsCompressed,
          );
      _enviromentVariables[searchTypeKey] =
          const String.fromEnvironment(searchTypeKey);
      _enviromentVariables[searchIndexKey] =
          const String.fromEnvironment(searchIndexKey);
      _enviromentVariables[searchThresholdKey] = const String.fromEnvironment(
        searchThresholdKey,
        defaultValue: defaultSearchThreshold,
      );
      _enviromentVariables[retrieveTopNResultsKey] =
          const String.fromEnvironment(
        retrieveTopNResultsKey,
        defaultValue: defaultRetrieveTopNResults,
      );
      _enviromentVariables[generationModelKey] =
          const String.fromEnvironment(generationModelKey);
      _enviromentVariables[generationModelContextLengthKey] =
          const String.fromEnvironment(
        generationModelContextLengthKey,
        defaultValue: defaultGenerationModelContextLength,
      );
      _enviromentVariables[generationApiUrlKey] =
          const String.fromEnvironment(generationApiUrlKey);
      _enviromentVariables[generationApiKey] =
          const String.fromEnvironment(generationApiKey);
      _enviromentVariables[systemPromptKey] = const String.fromEnvironment(
        systemPromptKey,
        defaultValue: defaultSystemPrompt,
      );
      _enviromentVariables[promptTemplateKey] = const String.fromEnvironment(
        promptTemplateKey,
        defaultValue: defaultPromptTemplate,
      );
      _enviromentVariables[temperatureKey] = const String.fromEnvironment(
        temperatureKey,
        defaultValue: defaultTemperature,
      );
      _enviromentVariables[topPKey] = const String.fromEnvironment(
        topPKey,
        defaultValue: defaultTopP,
      );
      _enviromentVariables[frequencyPenaltyKey] = const String.fromEnvironment(
        frequencyPenaltyKey,
        defaultValue: defaultFrequencyPenalty,
      );
      _enviromentVariables[frequencyPenaltyEnabledKey] =
          const String.fromEnvironment(
        frequencyPenaltyEnabledKey,
        defaultValue: defaultFrequencyPenaltyEnabled,
      ); 
      _enviromentVariables[presencePenaltyKey] = const String.fromEnvironment(
        presencePenaltyKey,
        defaultValue: defaultPresencePenalty,
      );
      _enviromentVariables[presencePenaltyEnabledKey] =
          const String.fromEnvironment(
        presencePenaltyEnabledKey,
        defaultValue: defaultPresencePenaltyEnabled,
      );           
      _enviromentVariables[maxTokensKey] = const String.fromEnvironment(
        maxTokensKey,
        defaultValue: defaultMaxTokens,
      );
      _enviromentVariables[stopKey] = const String.fromEnvironment(stopKey);
      _enviromentVariables[streamKey] = const String.fromEnvironment(
        streamKey, 
        defaultValue: defaultStream,
      );
    }
  }

  Future<void> initialise(String tablePrefix) async {
    if (_settings.isEmpty) {
      _initialiseEnvironmentVariables();
      await _loadLlmProviders();
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

  Future<void> _loadLlmProviders() async {
    final json = await rootBundle.loadString('packages/settings/assets/json/llm_providers.json');
    final llmProviderMaps = List<Map<String, dynamic>>.from(
      jsonDecode(json) as List,
    );
    _llmProviders = {
      for (final llmProviderMap in llmProviderMaps)
        llmProviderMap['id'] as String: LlmProvider.fromJson(llmProviderMap),
    };
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

  void clear() {
    _settings.clear();
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
