import 'dart:convert';

import 'package:database/database.dart';
import 'package:flutter/services.dart';
import 'package:settings/src/app/app.dialogs.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewModel extends ReactiveViewModel with FormStateHelper {
  SettingsViewModel(
    this.tablePrefix,
    this.redefineEmbeddingIndexFunction, {
    required this.inPackage,
  });
  final String tablePrefix;
  final bool inPackage;
  final _log = getLogger('SettingsViewModel');
  final _isPanelExpanded = List.filled(4, true);
  final _settingService = locator<SettingService>();
  final _dialogService = locator<DialogService>();
  final _connectionSettingService = locator<ConnectionSettingService>();
  final Future<String?> Function(
    String tablePrefix,
    String dimensions,
  )? redefineEmbeddingIndexFunction;

  @override
  List<ListenableServiceMixin> get listenableServices => [_settingService];

  bool isPanelExpanded(int index) => _isPanelExpanded[index];

  bool _stream = true;
  bool get stream => _stream;

  bool _embeddingsCompressed = true;
  bool get embeddingsCompressed => _embeddingsCompressed;

  late List<LlmProvider> _llmProviders;
  List<LlmProvider> get llmProviders => _llmProviders;
  String get llmProvider => _settingService.get(llmProviderKey).value;
  LlmProvider? get llmProviderSelected {
    final value = _settingService.get(llmProviderKey).value;
    if (llmProvider.isEmpty) {
      return null;
    } else {
      return llmProviders.firstWhere(
        (llmProvider) => llmProvider.name == value,
      );
    }
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setEmbeddingsCompressed(bool value) async {
    await _settingService.set(
      tablePrefix,
      embeddingsCompressedKey,
      value.toString(),
    );
    _embeddingsCompressed = value;
  }

  void setPanelExpanded(int index, {required bool isExpanded}) {
    _isPanelExpanded[index] = isExpanded;

    notifyListeners();
  }

  Future<void> initialise() async {
    _log.d(
      'tablePrefix: $tablePrefix, inPackage: $inPackage',
    );
    if (inPackage) {
      await connectDatabase();
    }
    setBusy(true);
    await loadLlmProviders();
    if (inPackage) {
      await _settingService.initialise(tablePrefix);
    }
    _settingService.clearFormValuesFunction = clearFormValues;
    _stream = bool.parse(_settingService.get(streamKey).value);
    _embeddingsCompressed = bool.parse(
      _settingService.get(embeddingsCompressedKey).value,
    );

    final splitApiUrl = _settingService.get(splitApiUrlKey);
    if (splitApiUrl.id != null) {
      splitApiUrlValue = splitApiUrl.value;
    }

    final chunkSize = _settingService.get(chunkSizeKey);
    if (chunkSize.id != null) {
      chunkSizeValue = chunkSize.value;
    }

    final chunkOverlap = _settingService.get(chunkOverlapKey);
    if (chunkOverlap.id != null) {
      chunkOverlapValue = chunkOverlap.value;
    }

    final embeddingsModel = _settingService.get(embeddingsModelKey);
    if (embeddingsModel.id != null) {
      embeddingsModelValue = embeddingsModel.value;
    }

    final embeddingsApiUrl = _settingService.get(embeddingsApiUrlKey);
    if (embeddingsApiUrl.id != null) {
      embeddingsApiUrlValue = embeddingsApiUrl.value;
    }

    final embeddingsApiKeyVal = _settingService.get(embeddingsApiKey);
    if (embeddingsApiKeyVal.id != null) {
      embeddingsApiKeyValue = embeddingsApiKeyVal.value;
    }

    final embeddingsDimensions = _settingService.get(embeddingsDimensionsKey);
    if (embeddingsDimensions.id != null) {
      embeddingsDimensionsValue = embeddingsDimensions.value;
    }

    final embeddingsApiBatchSize =
        _settingService.get(embeddingsApiBatchSizeKey);
    if (embeddingsApiBatchSize.id != null) {
      embeddingsApiBatchSizeValue = embeddingsApiBatchSize.value;
    }

    final embeddingsDatabaseBatchSize =
        _settingService.get(embeddingsDatabaseBatchSizeKey);
    if (embeddingsDatabaseBatchSize.id != null) {
      embeddingsDatabaseBatchSizeValue = embeddingsDatabaseBatchSize.value;
    }

    final searchType = _settingService.get(searchTypeKey);
    if (searchType.id != null) {
      searchTypeValue = searchType.value;
    }

    final searchIndex = _settingService.get(searchIndexKey);
    if (searchIndex.id != null) {
      searchIndexValue = searchIndex.value;
    }

    final searchThreshold = _settingService.get(searchThresholdKey);
    if (searchThreshold.id != null) {
      searchThresholdValue = searchThreshold.value;
    }

    final retrieveTopNResults = _settingService.get(retrieveTopNResultsKey);
    if (retrieveTopNResults.id != null) {
      retrieveTopNResultsValue = retrieveTopNResults.value;
    }

    final generationModel = _settingService.get(generationModelKey);
    if (generationModel.id != null) {
      generationModelValue = generationModel.value;
    }

    final generationApiUrl = _settingService.get(generationApiUrlKey);
    if (generationApiUrl.id != null) {
      generationApiUrlValue = generationApiUrl.value;
    }

    final generationApiKeyVal = _settingService.get(generationApiKey);
    if (generationApiKeyVal.id != null) {
      generationApiKeyValue = generationApiKeyVal.value;
    }

    final temperature = _settingService.get(temperatureKey);
    if (temperature.id != null) {
      temperatureValue = temperature.value;
    }

    final topP = _settingService.get(topPKey);
    if (topP.id != null) {
      topPValue = topP.value;
    }

    final repetitionPenalty = _settingService.get(repetitionPenaltyKey);
    if (repetitionPenalty.id != null) {
      repetitionPenaltyValue = repetitionPenalty.value;
    }

    final maxTokens = _settingService.get(maxTokensKey);
    if (maxTokens.id != null) {
      maxTokensValue = maxTokens.value;
    }

    final stop = _settingService.get(stopKey);
    if (stop.id != null) {
      stopValue = stop.value;
    }
    setBusy(false);
  }

  Future<void> loadLlmProviders() async {
    final json = await rootBundle.loadString('packages/settings/assets/json/llm_providers.json');
    _llmProviders = List<Map<String, dynamic>>.from(
      jsonDecode(json) as List,
    ).map(LlmProvider.fromJson).toList();
  }

  Future<void> connectDatabase() async {
    var confirmed = false;
    if (!await _connectionSettingService.autoConnect()) {
      while (!confirmed) {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.connection,
          title: 'Connection',
          description: 'Create database connection',
        );

        confirmed = response?.confirmed ?? false;
      }
    }
  }

  void clearFormValues() {
    const empty = '';
    splitApiUrlValue = empty;
    chunkSizeValue = empty;
    chunkOverlapValue = empty;
    embeddingsModelValue = empty;
    embeddingsApiUrlValue = empty;
    embeddingsApiKeyValue = empty;
    embeddingsDimensionsValue = empty;
    embeddingsApiBatchSizeValue = empty;
    embeddingsDatabaseBatchSizeValue = empty;
    searchTypeValue = empty;
    searchIndexValue = empty;
    searchThresholdValue = empty;
    retrieveTopNResultsValue = empty;
    generationModelValue = empty;
    generationApiUrlValue = empty;
    generationApiKeyValue = empty;
    temperatureValue = empty;
    topPValue = empty;
    repetitionPenaltyValue = empty;
    maxTokensValue = empty;
    stopValue = empty;
  }

  Future<void> setSplitApiUrl() async {
    if (hasSplitApiUrl && !hasSplitApiUrlValidationMessage) {
      await _settingService.set(
        tablePrefix,
        splitApiUrlKey,
        splitApiUrlValue!,
      );
    }
  }

  Future<void> setChunkSize() async {
    if (chunkSizeValue != null && !hasChunkSizeValidationMessage) {
      await _settingService.set(
        tablePrefix,
        chunkSizeKey,
        chunkSizeValue!,
      );
    }
  }

  Future<void> setChunkOverlap() async {
    if (chunkOverlapValue != null && !hasChunkOverlapValidationMessage) {
      await _settingService.set(
        tablePrefix,
        chunkOverlapKey,
        chunkOverlapValue!,
      );
    }
  }

  Future<void> setEmbeddingsModel() async {
    if (embeddingsModelValue != null && !hasEmbeddingsModelValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsModelKey,
        embeddingsModelValue!,
      );
    }
  }

  Future<void> setEmbeddingsApiUrl() async {
    if (embeddingsApiUrlValue != null &&
        !hasEmbeddingsApiUrlValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsApiUrlKey,
        embeddingsApiUrlValue!,
      );
    }
  }

  Future<void> setEmbeddingsApiKey() async {
    if (embeddingsApiKeyValue != null &&
        !hasEmbeddingsApiKeyValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsApiKey,
        embeddingsApiKeyValue!,
      );
    }
  }

  Future<void> setEmbeddingsDimensions() async {
    final embeddingsDimensions =
        _settingService.get(embeddingsDimensionsKey).value;
    if (embeddingsDimensionsValue != null &&
        embeddingsDimensionsValue!.isNotEmpty &&
        embeddingsDimensionsValue != embeddingsDimensions &&
        !hasEmbeddingsDimensionsValidationMessage) {
      String? redefineEmbeddingIndexError;
      if (redefineEmbeddingIndexFunction != null) {
        redefineEmbeddingIndexError = await redefineEmbeddingIndexFunction!(
          tablePrefix,
          embeddingsDimensionsValue!,
        );
      }
      _log.d('redefineEmbeddingIndexError $redefineEmbeddingIndexError');
      if (redefineEmbeddingIndexError != null) {
        fieldsValidationMessages[EmbeddingsDimensionsValueKey] =
            redefineEmbeddingIndexError;
        notifyListeners();
      } else {
        await _settingService.set(
          tablePrefix,
          embeddingsDimensionsKey,
          embeddingsDimensionsValue!,
        );
      }
    }
  }

  Future<void> setEmbeddingsApiBatchSize() async {
    if (embeddingsApiBatchSizeValue != null &&
        !hasEmbeddingsApiBatchSizeValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsApiBatchSizeKey,
        embeddingsApiBatchSizeValue!,
      );
    }
  }

  Future<void> setEmbeddingsDatabaseBatchSize() async {
    if (embeddingsDatabaseBatchSizeValue != null &&
        !hasEmbeddingsDatabaseBatchSizeValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsDatabaseBatchSizeKey,
        embeddingsDatabaseBatchSizeValue!,
      );
    }
  }

  Future<void> setSearchType() async {
    if (searchTypeValue != null && !hasSearchTypeValidationMessage) {
      await _settingService.set(
        tablePrefix,
        searchTypeKey,
        searchTypeValue!,
      );
    }
  }

  Future<void> setSearchIndex() async {
    if (searchIndexValue != null && !hasSearchIndexValidationMessage) {
      await _settingService.set(
        tablePrefix,
        searchIndexKey,
        searchIndexValue!,
      );
    }
  }

  Future<void> setSearchThreshold() async {
    if (searchThresholdValue != null && !hasSearchThresholdValidationMessage) {
      await _settingService.set(
        tablePrefix,
        searchThresholdKey,
        searchThresholdValue!,
      );
    }
  }

  Future<void> setRetrieveTopNResults() async {
    if (retrieveTopNResultsValue != null &&
        !hasRetrieveTopNResultsValidationMessage) {
      await _settingService.set(
        tablePrefix,
        retrieveTopNResultsKey,
        retrieveTopNResultsValue!,
      );
    }
  }

  Future<void> setGenerationModel() async {
    if (generationModelValue != null && !hasGenerationModelValidationMessage) {
      await _settingService.set(
        tablePrefix,
        generationModelKey,
        generationModelValue!,
      );
    }
  }

  Future<void> setGenerationApiUrl() async {
    if (generationApiUrlValue != null &&
        !hasGenerationApiUrlValidationMessage) {
      await _settingService.set(
        tablePrefix,
        generationApiUrlKey,
        generationApiUrlValue!,
      );
    }
  }

  Future<void> setGenerationApiKey() async {
    if (generationApiKeyValue != null &&
        !hasGenerationApiKeyValidationMessage) {
      await _settingService.set(
        tablePrefix,
        generationApiKey,
        generationApiKeyValue!,
      );
    }
  }

  Future<void> setTemperature() async {
    if (temperatureValue != null && !hasTemperatureValidationMessage) {
      await _settingService.set(
        tablePrefix,
        temperatureKey,
        temperatureValue!,
      );
    }
  }

  Future<void> setTopP() async {
    if (topPValue != null && !hasTopPValidationMessage) {
      await _settingService.set(
        tablePrefix,
        topPKey,
        topPValue!,
      );
    }
  }

  Future<void> setRepetitionPenalty() async {
    if (repetitionPenaltyValue != null &&
        !hasRepetitionPenaltyValidationMessage) {
      await _settingService.set(
        tablePrefix,
        repetitionPenaltyKey,
        repetitionPenaltyValue!,
      );
    }
  }

  Future<void> setMaxTokens() async {
    if (maxTokensValue != null && !hasMaxTokensValidationMessage) {
      await _settingService.set(
        tablePrefix,
        maxTokensKey,
        maxTokensValue!,
      );
    }
  }

  Future<void> setStop() async {
    if (stopValue != null && !hasStopValidationMessage) {
      await _settingService.set(
        tablePrefix,
        stopKey,
        stopValue!,
      );
    }
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setStream(bool value) async {
    await _settingService.set(
      tablePrefix,
      streamKey,
      value.toString(),
    );
    _stream = value;
  }

  Future<void> setLlmProvider(String value) async {
    await _settingService.set(
      tablePrefix,
      llmProviderKey,
      value,
    );
    if (value.isNotEmpty) {
      final llmProvider = llmProviderSelected!;
      _log.d('llmProviderSelected ${llmProvider.toJson()}');
      await _settingService.set(
        tablePrefix,
        embeddingsModelKey,
        llmProvider.embeddings.model,
      );
      embeddingsModelValue = llmProvider.embeddings.model;

      final embeddingsApiUrl = '${llmProvider.baseUrl}$embeddingsApiUriPath';
      await _settingService.set(
        tablePrefix,
        embeddingsApiUrlKey,
        embeddingsApiUrl,
      );
      embeddingsApiUrlValue = embeddingsApiUrl;
      
      final embeddingModel = llmProvider.embeddings.models.firstWhere(
        (model) => llmProvider.embeddings.model == model.name,
        orElse: EmbeddingModel.nullObject,
      );
      if (llmProvider.embeddings.dimensions != null) {
        embeddingsDimensionsValue = llmProvider.embeddings.dimensions.toString();
      } else {
        if (embeddingModel.name != 'null') {
          embeddingsDimensionsValue = embeddingModel.dimensions.toString();
        }
      }
      await setEmbeddingsDimensions();

      await _settingService.set(
        tablePrefix,
        generationModelKey,
        llmProvider.chatCompletions.model,
      );
      generationModelValue = llmProvider.chatCompletions.model;

      final generationApiUrl = '${llmProvider.baseUrl}$generationApiUriPath'; 
      await _settingService.set(
        tablePrefix,
        generationApiUrlKey,
        generationApiUrl,
      );
      generationApiUrlValue = generationApiUrl;

      await _settingService.set(
        tablePrefix,
        temperatureKey,
        llmProvider.chatCompletions.temperature.toString(),
      );
      temperatureValue = llmProvider.chatCompletions.temperature.toString();

      await _settingService.set(
        tablePrefix,
        maxTokensKey,
        llmProvider.chatCompletions.maxTokens.toString(),
      );
      maxTokensValue = llmProvider.chatCompletions.maxTokens.toString();

      await _settingService.set(
        tablePrefix,
        topPKey,
        llmProvider.chatCompletions.topP.toString(),
      );
      topPValue = llmProvider.chatCompletions.topP.toString();

      await _settingService.set(
        tablePrefix,
        repetitionPenaltyKey,
        llmProvider.chatCompletions.frequencyPenalty.toString(),
      );
      repetitionPenaltyValue =
          llmProvider.chatCompletions.frequencyPenalty.toString();

      if (llmProvider.chatCompletions.stop.isNotEmpty) {
        final stop = llmProvider.chatCompletions.stop.join(',');
        await _settingService.set(
          tablePrefix,
          stopKey,
          stop,
        );
        stopValue = stop;
      }
    }
  }
}
