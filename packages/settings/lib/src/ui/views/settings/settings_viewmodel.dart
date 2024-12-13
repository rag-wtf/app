// ignore_for_file: avoid_positional_boolean_parameters
import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:database/database.dart';
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
  final analyticsFacade = locator<AnalyticsFacade>();
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
  bool _analyticsEnabled = true;
  bool get analyticsEnabled => _analyticsEnabled;

  bool _embeddingsDimensionsEnabled = true;
  bool get embeddingsDimensionsEnabled => _embeddingsDimensionsEnabled;

  bool _frequencyPenaltyEnabled = true;
  bool get frequencyPenaltyEnabled => _frequencyPenaltyEnabled;

  bool _presencePenaltyEnabled = true;
  bool get presencePenaltyEnabled => _presencePenaltyEnabled;

  String get llmProviderId => _settingService.get(llmProviderKey).value;
  Map<String, LlmProvider> get llmProviders => _settingService.llmProviders;

  LlmProvider? get llmProviderSelected {
    if (llmProviderId.isEmpty) {
      return null;
    } else {
      return llmProviders[llmProviderId];
    }
  }

  Future<void> setEmbeddingsCompressed(bool value) async {
    await _settingService.set(
      tablePrefix,
      embeddingsCompressedKey,
      value.toString(),
    );
    _embeddingsCompressed = value;
    unawaited(analyticsFacade.trackCompressedToggled(enabled: value));
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    await _settingService.setAnalyticsEnabled(
      tablePrefix,
      enabled: value,
    );
    _analyticsEnabled = value;
  }

  Future<void> setEmbeddingsDimensionsEnabled(bool value) async {
    await _settingService.set(
      tablePrefix,
      embeddingsDimensionsEnabledKey,
      value.toString(),
    );
    _embeddingsDimensionsEnabled = value;
    unawaited(analyticsFacade.trackDimensionsToggled(enabled: value));
  }

  Future<void> setFrequencyPenaltyEnabled(bool value) async {
    await _settingService.set(
      tablePrefix,
      frequencyPenaltyEnabledKey,
      value.toString(),
    );
    _frequencyPenaltyEnabled = value;
    unawaited(analyticsFacade.trackFrequencyPenaltyToggled(enabled: value));
  }

  Future<void> setPresencePenaltyEnabled(bool value) async {
    await _settingService.set(
      tablePrefix,
      presencePenaltyEnabledKey,
      value.toString(),
    );
    _presencePenaltyEnabled = value;
    unawaited(analyticsFacade.trackPresencePenaltyToggled(enabled: value));
  }

  void setPanelExpanded(int index, {required bool isExpanded}) {
    _isPanelExpanded[index] = isExpanded;

    notifyListeners();
  }

  Future<void> initialise() async {
    _log.d(
      'tablePrefix: $tablePrefix, inPackage: $inPackage',
    );
    setBusy(true);
    if (inPackage) {
      await connectDatabase();
      await _settingService.initialise(
        tablePrefix,
        analyticsEnabled: true,
      );
    }
    _settingService.clearFormValuesFunction = clearFormValues;
    _stream = bool.parse(_settingService.get(streamKey).value);
    _embeddingsCompressed = bool.parse(
      _settingService.get(embeddingsCompressedKey).value,
    );
    _embeddingsDimensionsEnabled = bool.parse(
      _settingService.get(embeddingsDimensionsEnabledKey).value,
    );
    _frequencyPenaltyEnabled = bool.parse(
      _settingService.get(frequencyPenaltyEnabledKey).value,
    );
    _presencePenaltyEnabled = bool.parse(
      _settingService.get(presencePenaltyEnabledKey).value,
    );
    _analyticsEnabled = bool.parse(
      _settingService.get(analyticsEnabledKey).value,
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

    final embeddingsModelContextLength =
        _settingService.get(embeddingsModelContextLengthKey);
    if (embeddingsModelContextLength.id != null) {
      embeddingsModelContextLengthValue = embeddingsModelContextLength.value;
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

    final generationModelContextLength =
        _settingService.get(generationModelContextLengthKey);
    if (generationModelContextLength.id != null) {
      generationModelContextLengthValue = generationModelContextLength.value;
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

    final frequencyPenalty = _settingService.get(frequencyPenaltyKey);
    if (frequencyPenalty.id != null) {
      frequencyPenaltyValue = frequencyPenalty.value;
    }

    final presencePenalty = _settingService.get(presencePenaltyKey);
    if (presencePenalty.id != null) {
      presencePenaltyValue = presencePenalty.value;
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
    embeddingsModelContextLengthValue = empty;
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
    generationModelContextLengthValue = empty;
    generationApiUrlValue = empty;
    generationApiKeyValue = empty;
    temperatureValue = empty;
    topPValue = empty;
    frequencyPenaltyValue = empty;
    presencePenaltyValue = empty;
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

  Future<void> setEmbeddingsModelContextLength() async {
    if (embeddingsModelContextLengthValue != null &&
        !hasEmbeddingsModelContextLengthValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsModelContextLengthKey,
        embeddingsModelContextLengthValue!,
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

  Future<void> setGenerationModelContextLength() async {
    if (generationModelContextLengthValue != null &&
        !hasGenerationModelContextLengthValidationMessage) {
      await _settingService.set(
        tablePrefix,
        generationModelContextLengthKey,
        generationModelContextLengthValue!,
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

  Future<void> setFrequencyPenalty() async {
    if (frequencyPenaltyValue != null &&
        !hasFrequencyPenaltyValidationMessage) {
      await _settingService.set(
        tablePrefix,
        frequencyPenaltyKey,
        frequencyPenaltyValue!,
      );
    }
  }

  Future<void> setPresencePenalty() async {
    if (presencePenaltyValue != null && !hasPresencePenaltyValidationMessage) {
      await _settingService.set(
        tablePrefix,
        presencePenaltyKey,
        presencePenaltyValue!,
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

  Future<void> setStream(bool value) async {
    await _settingService.set(
      tablePrefix,
      streamKey,
      value.toString(),
    );
    _stream = value;
    unawaited(analyticsFacade.trackStreamingToggled(enabled: value));
  }

  Future<void> setLlmProvider(String value) async {
    await _settingService.set(
      tablePrefix,
      llmProviderKey,
      value,
    );
    if (value.isNotEmpty) {
      unawaited(analyticsFacade.trackLlmProviderSelected(value));
      final llmProvider = llmProviderSelected!;
      _log.d('llmProviderSelected $llmProvider');
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

      final maxBatchSize = llmProvider.embeddings.maxBatchSize;
      if (maxBatchSize != null) {
        await _settingService.set(
          tablePrefix,
          embeddingsApiBatchSizeKey,
          maxBatchSize.toString(),
        );
        embeddingsApiBatchSizeValue = maxBatchSize.toString();
      }

      final embeddingModel = llmProvider.embeddings.models.firstWhere(
        (model) => llmProvider.embeddings.model == model.name,
        orElse: EmbeddingModel.nullObject,
      );
      unawaited(
        analyticsFacade.trackEmbeddingModelSelected(embeddingModel.name),
      );

      await setEmbeddingsModelContextLengthAndDimensions(embeddingModel);
      await setEmbeddingsDimensionsEnabled(
        llmProvider.embeddings.dimensionsEnabled,
      );

      await _settingService.set(
        tablePrefix,
        generationModelKey,
        llmProvider.chatCompletions.model,
      );
      generationModelValue = llmProvider.chatCompletions.model;

      final generationModel = llmProvider.chatCompletions.models.firstWhere(
        (model) => llmProvider.chatCompletions.model == model.name,
        orElse: ChatModel.nullObject,
      );
      unawaited(
        analyticsFacade.trackGenerationModelSelected(generationModel.name),
      );

      await setGenerationModelContextLengthWith(generationModel);

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

      if (llmProvider.chatCompletions.frequencyPenaltyEnabled) {
        await _settingService.set(
          tablePrefix,
          frequencyPenaltyKey,
          llmProvider.chatCompletions.frequencyPenalty.toString(),
        );
        frequencyPenaltyValue =
            llmProvider.chatCompletions.frequencyPenalty.toString();
      }
      await setFrequencyPenaltyEnabled(
        llmProvider.chatCompletions.frequencyPenaltyEnabled,
      );

      if (llmProvider.chatCompletions.presencePenaltyEnabled) {
        await _settingService.set(
          tablePrefix,
          presencePenaltyKey,
          llmProvider.chatCompletions.presencePenalty.toString(),
        );
        presencePenaltyValue =
            llmProvider.chatCompletions.presencePenalty.toString();
      }
      await setPresencePenaltyEnabled(
        llmProvider.chatCompletions.presencePenaltyEnabled,
      );

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

  Future<void> setGenerationModelContextLengthWith(
    ChatModel generationModel,
  ) async {
    if (generationModel.name != 'null') {
      await _settingService.set(
        tablePrefix,
        generationModelContextLengthKey,
        generationModel.contextLength.toString(),
      );
      generationModelContextLengthValue =
          generationModel.contextLength.toString();
    }
  }

  Future<void> setEmbeddingsModelContextLengthAndDimensions(
    EmbeddingModel embeddingModel,
  ) async {
    if (embeddingModel.name != 'null') {
      await _settingService.set(
        tablePrefix,
        embeddingsModelContextLengthKey,
        embeddingModel.contextLength.toString(),
      );
      embeddingsModelContextLengthValue =
          embeddingModel.contextLength.toString();
    }

    if (embeddingModel.name != 'null' &&
        llmProviderSelected?.embeddings.model != embeddingModel.name) {
      embeddingsDimensionsValue = embeddingModel.dimensions.toString();
    } else if (llmProviderSelected?.embeddings.dimensions != null) {
      embeddingsDimensionsValue =
          llmProviderSelected!.embeddings.dimensions.toString();
    }
    await setEmbeddingsDimensions();
  }

  Future<void> onEmbeddingModelSelected(EmbeddingModel model) async {
    _log.d(model);
    if (model.name != embeddingsModelValue) {
      unawaited(
        analyticsFacade.trackEmbeddingModelSelected(model.name),
      );
      String? redefineEmbeddingIndexError;
      if (redefineEmbeddingIndexFunction != null) {
        redefineEmbeddingIndexError = await redefineEmbeddingIndexFunction!(
          tablePrefix,
          model.dimensions.toString(),
        );
      }
      _log.d('redefineEmbeddingIndexError $redefineEmbeddingIndexError');
      if (redefineEmbeddingIndexError != null) {
        fieldsValidationMessages[EmbeddingsModelValueKey] =
            redefineEmbeddingIndexError.replaceFirst('dimensions', 'model');
        notifyListeners();
      } else {
        await _settingService.set(
          tablePrefix,
          embeddingsModelKey,
          model.name,
        );
        embeddingsModelValue = model.name;
        await setEmbeddingsModelContextLengthAndDimensions(model);
      }
    }
  }

  Future<void> onGenerationModelSelected(ChatModel model) async {
    _log.d(model);
    if (model.name != generationModelValue) {
      unawaited(
        analyticsFacade.trackGenerationModelSelected(model.name),
      );      
      await _settingService.set(
        tablePrefix,
        generationModelKey,
        model.name,
      );
      generationModelValue = model.name;

      await setGenerationModelContextLengthWith(model);

      notifyListeners();
    }
  }
}
