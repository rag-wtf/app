import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:stacked/stacked.dart';

class SettingsViewModel extends FutureViewModel<void> with FormStateHelper {
  SettingsViewModel(this.tablePrefix);
  final String tablePrefix;
  final _isPanelExpanded = List.filled(4, true);
  final _settingService = locator<SettingService>();
  bool isPanelExpanded(int index) => _isPanelExpanded[index];

  bool get stream =>
      bool.parse(_settingService.get(streamKey, type: bool).value);

  void setPanelExpanded(int index, {required bool isExpanded}) {
    _isPanelExpanded[index] = isExpanded;

    notifyListeners();
  }

  Future<void> _initialise() async {
    await _settingService.initialise(tablePrefix);

    final dataIngestionApiUrl = _settingService.get(dataIngestionApiUrlKey);
    if (dataIngestionApiUrl.id != null) {
      dataIngestionApiUrlValue = dataIngestionApiUrl.value;
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

    final embeddingsDimension =
        _settingService.get(embeddingsDimensionKey, type: int);
    if (embeddingsDimension.id != null) {
      embeddingsDimensionValue = embeddingsDimension.value;
    }

    final embeddingsApiBatchSize =
        _settingService.get(embeddingsApiBatchSizeKey, type: int);
    if (embeddingsApiBatchSize.id != null) {
      embeddingsApiBatchSizeValue = embeddingsApiBatchSize.value;
    }

    final similaritySearchType = _settingService.get(similaritySearchTypeKey);
    if (similaritySearchType.id != null) {
      similaritySearchTypeValue = similaritySearchType.value;
    }

    final similaritySearchIndex = _settingService.get(similaritySearchIndexKey);
    if (similaritySearchIndex.id != null) {
      similaritySearchIndexValue = similaritySearchIndex.value;
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

    final maxNewTokens = _settingService.get(maxNewTokensKey, type: int);
    if (maxNewTokens.id != null) {
      maxNewTokensValue = maxNewTokens.value;
    }

    final stop = _settingService.get(stopKey);
    if (stop.id != null) {
      stopValue = stop.value;
    }
  }

  Future<void> setDataIngestionApiUrl() async {
    if (hasDataIngestionApiUrl && !hasDataIngestionApiUrlValidationMessage) {
      await _settingService.set(
        tablePrefix,
        dataIngestionApiUrlKey,
        dataIngestionApiUrlValue!,
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

  Future<void> setEmbeddingsDimension() async {
    if (embeddingsDimensionValue != null &&
        !hasEmbeddingsDimensionValidationMessage) {
      await _settingService.set(
        tablePrefix,
        embeddingsDimensionKey,
        embeddingsDimensionValue!,
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

  Future<void> setSimilaritySearchType() async {
    if (similaritySearchTypeValue != null &&
        !hasSimilaritySearchTypeValidationMessage) {
      await _settingService.set(
        tablePrefix,
        similaritySearchTypeKey,
        similaritySearchTypeValue!,
      );
    }
  }

  Future<void> setSimilaritySearchIndex() async {
    if (similaritySearchIndexValue != null &&
        !hasSimilaritySearchIndexValidationMessage) {
      await _settingService.set(
        tablePrefix,
        similaritySearchIndexKey,
        similaritySearchIndexValue!,
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

  Future<void> setMaxNewTokens() async {
    if (maxNewTokensValue != null && !hasMaxNewTokensValidationMessage) {
      await _settingService.set(
        tablePrefix,
        maxNewTokensKey,
        maxNewTokensValue!,
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
    notifyListeners();
  }

  @override
  Future<void> futureToRun() async {
    await _initialise();
  }
}
