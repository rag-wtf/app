import 'package:database/database.dart';
import 'package:settings/src/app/app.dialogs.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewModel extends ReactiveViewModel with FormStateHelper {
  SettingsViewModel(this.tablePrefix, {required this.hasConnectDatabase});
  final String tablePrefix;
  final bool hasConnectDatabase;
  final _log = getLogger('SettingsViewModel');
  final _isPanelExpanded = List.filled(4, true);
  final _settingService = locator<SettingService>();
  final _dialogService = locator<DialogService>();
  final _connectionSettingService = locator<ConnectionSettingService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settingService];

  bool isPanelExpanded(int index) => _isPanelExpanded[index];

  bool _stream = true;
  bool get stream => _stream;

  bool _embeddingsCompressed = true;
  bool get embeddingsCompressed => _embeddingsCompressed;

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
      'tablePrefix: $tablePrefix, hasConnectDatabase: $hasConnectDatabase',
    );
    if (hasConnectDatabase) {
      await connectDatabase();
    }
    setBusy(true);
    await _settingService.initialise(tablePrefix);
    _settingService.clearFormValuesFunction = clearFormValues;
    _stream = bool.parse(_settingService.get(streamKey, type: bool).value);
    _embeddingsCompressed = bool.parse(
        _settingService.get(embeddingsCompressedKey, type: bool).value);
    final splitApiUrl = _settingService.get(splitApiUrlKey);
    if (splitApiUrl.id != null) {
      splitApiUrlValue = splitApiUrl.value;
    }

    final chunkSize = _settingService.get(chunkSizeKey, type: int);
    if (chunkSize.id != null) {
      chunkSizeValue = chunkSize.value;
    }

    final chunkOverlap = _settingService.get(chunkOverlapKey, type: int);
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

    final embeddingsDimensions =
        _settingService.get(embeddingsDimensionsKey, type: int);
    if (embeddingsDimensions.id != null) {
      embeddingsDimensionsValue = embeddingsDimensions.value;
    }

    final embeddingsApiBatchSize =
        _settingService.get(embeddingsApiBatchSizeKey, type: int);
    if (embeddingsApiBatchSize.id != null) {
      embeddingsApiBatchSizeValue = embeddingsApiBatchSize.value;
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

    final retrieveTopNResults =
        _settingService.get(retrieveTopNResultsKey, type: int);
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

    final promptTemplate = _settingService.get(promptTemplateKey);
    if (promptTemplate.id != null) {
      promptTemplateValue = promptTemplate.value;
    }

    final temperature = _settingService.get(temperatureKey, type: double);
    if (temperature.id != null) {
      temperatureValue = temperature.value;
    }

    final topP = _settingService.get(topPKey, type: double);
    if (topP.id != null) {
      topPValue = topP.value;
    }

    final repetitionPenalty =
        _settingService.get(repetitionPenaltyKey, type: double);
    if (repetitionPenalty.id != null) {
      repetitionPenaltyValue = repetitionPenalty.value;
    }

    final topK = _settingService.get(topKKey, type: int);
    if (topK.id != null) {
      topKValue = topK.value;
    }

    final maxTokens = _settingService.get(maxTokensKey, type: int);
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
    embeddingsApiUrlValue = empty;
    embeddingsApiKeyValue = empty;
    embeddingsDimensionsValue = empty;
    embeddingsApiBatchSizeValue = empty;
    searchTypeValue = empty;
    searchIndexValue = empty;
    searchThresholdValue = empty;
    retrieveTopNResultsValue = empty;
    generationModelValue = empty;
    generationApiUrlValue = empty;
    generationApiKeyValue = empty;
    promptTemplateValue = empty;
    temperatureValue = empty;
    topPValue = empty;
    repetitionPenaltyValue = empty;
    topKValue = empty;
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
    if (embeddingsDimensionsValue != null &&
        !hasEmbeddingsDimensionsValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsDimensionsKey,
        embeddingsDimensionsValue!,
      );
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

  Future<void> setPromptTemplate() async {
    if (promptTemplateValue != null && !hasPromptTemplateValidationMessage) {
      await _settingService.set(
        tablePrefix,
        promptTemplateKey,
        promptTemplateValue!,
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

  Future<void> setTopK() async {
    if (topKValue != null && !hasTopKValidationMessage) {
      await _settingService.set(
        tablePrefix,
        topKKey,
        topKValue!,
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
}
