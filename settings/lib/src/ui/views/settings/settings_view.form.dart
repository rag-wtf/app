// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:settings/src/ui/views/settings/settings_view.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String DataIngestionApiUrlValueKey = 'dataIngestionApiUrl';
const String ChunkSizeValueKey = 'chunkSize';
const String ChunkOverlapValueKey = 'chunkOverlap';
const String EmbeddingsApiUrlValueKey = 'embeddingsApiUrl';
const String EmbeddingsApiKeyValueKey = 'embeddingsApiKey';
const String EmbeddingsDimensionValueKey = 'embeddingsDimension';
const String EmbeddingsApiBatchSizeValueKey = 'embeddingsApiBatchSize';
const String SimilaritySearchTypeValueKey = 'similaritySearchType';
const String SimilaritySearchIndexValueKey = 'similaritySearchIndex';
const String RetrieveTopNResultsValueKey = 'retrieveTopNResults';
const String GenerationApiUrlValueKey = 'generationApiUrl';
const String GenerationApiKeyValueKey = 'generationApiKey';
const String PromptTemplateValueKey = 'promptTemplate';
const String TemperatureValueKey = 'temperature';
const String TopPValueKey = 'topP';
const String RepetitionPenaltyValueKey = 'repetitionPenalty';
const String TopKValueKey = 'topK';
const String MaxNewTokensValueKey = 'maxNewTokens';
const String StopValueKey = 'stop';
const String StreamValueKey = 'stream';

final Map<String, TextEditingController> _SettingsViewTextEditingControllers =
    {};

final Map<String, FocusNode> _SettingsViewFocusNodes = {};

final Map<String, String? Function(String?)?> _SettingsViewTextValidations = {
  DataIngestionApiUrlValueKey: SettingsValidators.validateUrl,
  ChunkSizeValueKey: null,
  ChunkOverlapValueKey: null,
  EmbeddingsApiUrlValueKey: null,
  EmbeddingsApiKeyValueKey: null,
  EmbeddingsDimensionValueKey: null,
  EmbeddingsApiBatchSizeValueKey:
      SettingsValidators.validateEmbeddingsApiBatchSize,
  SimilaritySearchTypeValueKey: null,
  SimilaritySearchIndexValueKey: null,
  RetrieveTopNResultsValueKey: null,
  GenerationApiUrlValueKey: null,
  GenerationApiKeyValueKey: null,
  PromptTemplateValueKey: null,
  TemperatureValueKey: null,
  TopPValueKey: null,
  RepetitionPenaltyValueKey: null,
  TopKValueKey: null,
  MaxNewTokensValueKey: null,
  StopValueKey: null,
  StreamValueKey: null,
};

mixin $SettingsView {
  TextEditingController get dataIngestionApiUrlController =>
      _getFormTextEditingController(DataIngestionApiUrlValueKey);
  TextEditingController get chunkSizeController =>
      _getFormTextEditingController(ChunkSizeValueKey);
  TextEditingController get chunkOverlapController =>
      _getFormTextEditingController(ChunkOverlapValueKey);
  TextEditingController get embeddingsApiUrlController =>
      _getFormTextEditingController(EmbeddingsApiUrlValueKey);
  TextEditingController get embeddingsApiKeyController =>
      _getFormTextEditingController(EmbeddingsApiKeyValueKey);
  TextEditingController get embeddingsDimensionController =>
      _getFormTextEditingController(EmbeddingsDimensionValueKey);
  TextEditingController get embeddingsApiBatchSizeController =>
      _getFormTextEditingController(EmbeddingsApiBatchSizeValueKey);
  TextEditingController get similaritySearchTypeController =>
      _getFormTextEditingController(SimilaritySearchTypeValueKey);
  TextEditingController get similaritySearchIndexController =>
      _getFormTextEditingController(SimilaritySearchIndexValueKey);
  TextEditingController get retrieveTopNResultsController =>
      _getFormTextEditingController(RetrieveTopNResultsValueKey);
  TextEditingController get generationApiUrlController =>
      _getFormTextEditingController(GenerationApiUrlValueKey);
  TextEditingController get generationApiKeyController =>
      _getFormTextEditingController(GenerationApiKeyValueKey);
  TextEditingController get promptTemplateController =>
      _getFormTextEditingController(PromptTemplateValueKey);
  TextEditingController get temperatureController =>
      _getFormTextEditingController(TemperatureValueKey);
  TextEditingController get topPController =>
      _getFormTextEditingController(TopPValueKey);
  TextEditingController get repetitionPenaltyController =>
      _getFormTextEditingController(RepetitionPenaltyValueKey);
  TextEditingController get topKController =>
      _getFormTextEditingController(TopKValueKey);
  TextEditingController get maxNewTokensController =>
      _getFormTextEditingController(MaxNewTokensValueKey);
  TextEditingController get stopController =>
      _getFormTextEditingController(StopValueKey);
  TextEditingController get streamController =>
      _getFormTextEditingController(StreamValueKey);

  FocusNode get dataIngestionApiUrlFocusNode =>
      _getFormFocusNode(DataIngestionApiUrlValueKey);
  FocusNode get chunkSizeFocusNode => _getFormFocusNode(ChunkSizeValueKey);
  FocusNode get chunkOverlapFocusNode =>
      _getFormFocusNode(ChunkOverlapValueKey);
  FocusNode get embeddingsApiUrlFocusNode =>
      _getFormFocusNode(EmbeddingsApiUrlValueKey);
  FocusNode get embeddingsApiKeyFocusNode =>
      _getFormFocusNode(EmbeddingsApiKeyValueKey);
  FocusNode get embeddingsDimensionFocusNode =>
      _getFormFocusNode(EmbeddingsDimensionValueKey);
  FocusNode get embeddingsApiBatchSizeFocusNode =>
      _getFormFocusNode(EmbeddingsApiBatchSizeValueKey);
  FocusNode get similaritySearchTypeFocusNode =>
      _getFormFocusNode(SimilaritySearchTypeValueKey);
  FocusNode get similaritySearchIndexFocusNode =>
      _getFormFocusNode(SimilaritySearchIndexValueKey);
  FocusNode get retrieveTopNResultsFocusNode =>
      _getFormFocusNode(RetrieveTopNResultsValueKey);
  FocusNode get generationApiUrlFocusNode =>
      _getFormFocusNode(GenerationApiUrlValueKey);
  FocusNode get generationApiKeyFocusNode =>
      _getFormFocusNode(GenerationApiKeyValueKey);
  FocusNode get promptTemplateFocusNode =>
      _getFormFocusNode(PromptTemplateValueKey);
  FocusNode get temperatureFocusNode => _getFormFocusNode(TemperatureValueKey);
  FocusNode get topPFocusNode => _getFormFocusNode(TopPValueKey);
  FocusNode get repetitionPenaltyFocusNode =>
      _getFormFocusNode(RepetitionPenaltyValueKey);
  FocusNode get topKFocusNode => _getFormFocusNode(TopKValueKey);
  FocusNode get maxNewTokensFocusNode =>
      _getFormFocusNode(MaxNewTokensValueKey);
  FocusNode get stopFocusNode => _getFormFocusNode(StopValueKey);
  FocusNode get streamFocusNode => _getFormFocusNode(StreamValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_SettingsViewTextEditingControllers.containsKey(key)) {
      return _SettingsViewTextEditingControllers[key]!;
    }

    _SettingsViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _SettingsViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_SettingsViewFocusNodes.containsKey(key)) {
      return _SettingsViewFocusNodes[key]!;
    }
    _SettingsViewFocusNodes[key] = FocusNode();
    return _SettingsViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    dataIngestionApiUrlController.addListener(() => _updateFormData(model));
    chunkSizeController.addListener(() => _updateFormData(model));
    chunkOverlapController.addListener(() => _updateFormData(model));
    embeddingsApiUrlController.addListener(() => _updateFormData(model));
    embeddingsApiKeyController.addListener(() => _updateFormData(model));
    embeddingsDimensionController.addListener(() => _updateFormData(model));
    embeddingsApiBatchSizeController.addListener(() => _updateFormData(model));
    similaritySearchTypeController.addListener(() => _updateFormData(model));
    similaritySearchIndexController.addListener(() => _updateFormData(model));
    retrieveTopNResultsController.addListener(() => _updateFormData(model));
    generationApiUrlController.addListener(() => _updateFormData(model));
    generationApiKeyController.addListener(() => _updateFormData(model));
    promptTemplateController.addListener(() => _updateFormData(model));
    temperatureController.addListener(() => _updateFormData(model));
    topPController.addListener(() => _updateFormData(model));
    repetitionPenaltyController.addListener(() => _updateFormData(model));
    topKController.addListener(() => _updateFormData(model));
    maxNewTokensController.addListener(() => _updateFormData(model));
    stopController.addListener(() => _updateFormData(model));
    streamController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    dataIngestionApiUrlController.addListener(() => _updateFormData(model));
    chunkSizeController.addListener(() => _updateFormData(model));
    chunkOverlapController.addListener(() => _updateFormData(model));
    embeddingsApiUrlController.addListener(() => _updateFormData(model));
    embeddingsApiKeyController.addListener(() => _updateFormData(model));
    embeddingsDimensionController.addListener(() => _updateFormData(model));
    embeddingsApiBatchSizeController.addListener(() => _updateFormData(model));
    similaritySearchTypeController.addListener(() => _updateFormData(model));
    similaritySearchIndexController.addListener(() => _updateFormData(model));
    retrieveTopNResultsController.addListener(() => _updateFormData(model));
    generationApiUrlController.addListener(() => _updateFormData(model));
    generationApiKeyController.addListener(() => _updateFormData(model));
    promptTemplateController.addListener(() => _updateFormData(model));
    temperatureController.addListener(() => _updateFormData(model));
    topPController.addListener(() => _updateFormData(model));
    repetitionPenaltyController.addListener(() => _updateFormData(model));
    topKController.addListener(() => _updateFormData(model));
    maxNewTokensController.addListener(() => _updateFormData(model));
    stopController.addListener(() => _updateFormData(model));
    streamController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          DataIngestionApiUrlValueKey: dataIngestionApiUrlController.text,
          ChunkSizeValueKey: chunkSizeController.text,
          ChunkOverlapValueKey: chunkOverlapController.text,
          EmbeddingsApiUrlValueKey: embeddingsApiUrlController.text,
          EmbeddingsApiKeyValueKey: embeddingsApiKeyController.text,
          EmbeddingsDimensionValueKey: embeddingsDimensionController.text,
          EmbeddingsApiBatchSizeValueKey: embeddingsApiBatchSizeController.text,
          SimilaritySearchTypeValueKey: similaritySearchTypeController.text,
          SimilaritySearchIndexValueKey: similaritySearchIndexController.text,
          RetrieveTopNResultsValueKey: retrieveTopNResultsController.text,
          GenerationApiUrlValueKey: generationApiUrlController.text,
          GenerationApiKeyValueKey: generationApiKeyController.text,
          PromptTemplateValueKey: promptTemplateController.text,
          TemperatureValueKey: temperatureController.text,
          TopPValueKey: topPController.text,
          RepetitionPenaltyValueKey: repetitionPenaltyController.text,
          TopKValueKey: topKController.text,
          MaxNewTokensValueKey: maxNewTokensController.text,
          StopValueKey: stopController.text,
          StreamValueKey: streamController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (final controller in _SettingsViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _SettingsViewFocusNodes.values) {
      focusNode.dispose();
    }

    _SettingsViewTextEditingControllers.clear();
    _SettingsViewFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get dataIngestionApiUrlValue =>
      this.formValueMap[DataIngestionApiUrlValueKey] as String?;
  String? get chunkSizeValue => this.formValueMap[ChunkSizeValueKey] as String?;
  String? get chunkOverlapValue =>
      this.formValueMap[ChunkOverlapValueKey] as String?;
  String? get embeddingsApiUrlValue =>
      this.formValueMap[EmbeddingsApiUrlValueKey] as String?;
  String? get embeddingsApiKeyValue =>
      this.formValueMap[EmbeddingsApiKeyValueKey] as String?;
  String? get embeddingsDimensionValue =>
      this.formValueMap[EmbeddingsDimensionValueKey] as String?;
  String? get embeddingsApiBatchSizeValue =>
      this.formValueMap[EmbeddingsApiBatchSizeValueKey] as String?;
  String? get similaritySearchTypeValue =>
      this.formValueMap[SimilaritySearchTypeValueKey] as String?;
  String? get similaritySearchIndexValue =>
      this.formValueMap[SimilaritySearchIndexValueKey] as String?;
  String? get retrieveTopNResultsValue =>
      this.formValueMap[RetrieveTopNResultsValueKey] as String?;
  String? get generationApiUrlValue =>
      this.formValueMap[GenerationApiUrlValueKey] as String?;
  String? get generationApiKeyValue =>
      this.formValueMap[GenerationApiKeyValueKey] as String?;
  String? get promptTemplateValue =>
      this.formValueMap[PromptTemplateValueKey] as String?;
  String? get temperatureValue =>
      this.formValueMap[TemperatureValueKey] as String?;
  String? get topPValue => this.formValueMap[TopPValueKey] as String?;
  String? get repetitionPenaltyValue =>
      this.formValueMap[RepetitionPenaltyValueKey] as String?;
  String? get topKValue => this.formValueMap[TopKValueKey] as String?;
  String? get maxNewTokensValue =>
      this.formValueMap[MaxNewTokensValueKey] as String?;
  String? get stopValue => this.formValueMap[StopValueKey] as String?;
  String? get streamValue => this.formValueMap[StreamValueKey] as String?;

  set dataIngestionApiUrlValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DataIngestionApiUrlValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      DataIngestionApiUrlValueKey,
    )) {
      _SettingsViewTextEditingControllers[DataIngestionApiUrlValueKey]?.text =
          value ?? '';
    }
  }

  set chunkSizeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({ChunkSizeValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(ChunkSizeValueKey)) {
      _SettingsViewTextEditingControllers[ChunkSizeValueKey]?.text =
          value ?? '';
    }
  }

  set chunkOverlapValue(String? value) {
    this.setData(
      this.formValueMap..addAll({ChunkOverlapValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(ChunkOverlapValueKey)) {
      _SettingsViewTextEditingControllers[ChunkOverlapValueKey]?.text =
          value ?? '';
    }
  }

  set embeddingsApiUrlValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmbeddingsApiUrlValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      EmbeddingsApiUrlValueKey,
    )) {
      _SettingsViewTextEditingControllers[EmbeddingsApiUrlValueKey]?.text =
          value ?? '';
    }
  }

  set embeddingsApiKeyValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmbeddingsApiKeyValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      EmbeddingsApiKeyValueKey,
    )) {
      _SettingsViewTextEditingControllers[EmbeddingsApiKeyValueKey]?.text =
          value ?? '';
    }
  }

  set embeddingsDimensionValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmbeddingsDimensionValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      EmbeddingsDimensionValueKey,
    )) {
      _SettingsViewTextEditingControllers[EmbeddingsDimensionValueKey]?.text =
          value ?? '';
    }
  }

  set embeddingsApiBatchSizeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmbeddingsApiBatchSizeValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      EmbeddingsApiBatchSizeValueKey,
    )) {
      _SettingsViewTextEditingControllers[EmbeddingsApiBatchSizeValueKey]
          ?.text = value ?? '';
    }
  }

  set similaritySearchTypeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({SimilaritySearchTypeValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      SimilaritySearchTypeValueKey,
    )) {
      _SettingsViewTextEditingControllers[SimilaritySearchTypeValueKey]?.text =
          value ?? '';
    }
  }

  set similaritySearchIndexValue(String? value) {
    this.setData(
      this.formValueMap..addAll({SimilaritySearchIndexValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      SimilaritySearchIndexValueKey,
    )) {
      _SettingsViewTextEditingControllers[SimilaritySearchIndexValueKey]?.text =
          value ?? '';
    }
  }

  set retrieveTopNResultsValue(String? value) {
    this.setData(
      this.formValueMap..addAll({RetrieveTopNResultsValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      RetrieveTopNResultsValueKey,
    )) {
      _SettingsViewTextEditingControllers[RetrieveTopNResultsValueKey]?.text =
          value ?? '';
    }
  }

  set generationApiUrlValue(String? value) {
    this.setData(
      this.formValueMap..addAll({GenerationApiUrlValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      GenerationApiUrlValueKey,
    )) {
      _SettingsViewTextEditingControllers[GenerationApiUrlValueKey]?.text =
          value ?? '';
    }
  }

  set generationApiKeyValue(String? value) {
    this.setData(
      this.formValueMap..addAll({GenerationApiKeyValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      GenerationApiKeyValueKey,
    )) {
      _SettingsViewTextEditingControllers[GenerationApiKeyValueKey]?.text =
          value ?? '';
    }
  }

  set promptTemplateValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PromptTemplateValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      PromptTemplateValueKey,
    )) {
      _SettingsViewTextEditingControllers[PromptTemplateValueKey]?.text =
          value ?? '';
    }
  }

  set temperatureValue(String? value) {
    this.setData(
      this.formValueMap..addAll({TemperatureValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(TemperatureValueKey)) {
      _SettingsViewTextEditingControllers[TemperatureValueKey]?.text =
          value ?? '';
    }
  }

  set topPValue(String? value) {
    this.setData(
      this.formValueMap..addAll({TopPValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(TopPValueKey)) {
      _SettingsViewTextEditingControllers[TopPValueKey]?.text = value ?? '';
    }
  }

  set repetitionPenaltyValue(String? value) {
    this.setData(
      this.formValueMap..addAll({RepetitionPenaltyValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(
      RepetitionPenaltyValueKey,
    )) {
      _SettingsViewTextEditingControllers[RepetitionPenaltyValueKey]?.text =
          value ?? '';
    }
  }

  set topKValue(String? value) {
    this.setData(
      this.formValueMap..addAll({TopKValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(TopKValueKey)) {
      _SettingsViewTextEditingControllers[TopKValueKey]?.text = value ?? '';
    }
  }

  set maxNewTokensValue(String? value) {
    this.setData(
      this.formValueMap..addAll({MaxNewTokensValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(MaxNewTokensValueKey)) {
      _SettingsViewTextEditingControllers[MaxNewTokensValueKey]?.text =
          value ?? '';
    }
  }

  set stopValue(String? value) {
    this.setData(
      this.formValueMap..addAll({StopValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(StopValueKey)) {
      _SettingsViewTextEditingControllers[StopValueKey]?.text = value ?? '';
    }
  }

  set streamValue(String? value) {
    this.setData(
      this.formValueMap..addAll({StreamValueKey: value}),
    );

    if (_SettingsViewTextEditingControllers.containsKey(StreamValueKey)) {
      _SettingsViewTextEditingControllers[StreamValueKey]?.text = value ?? '';
    }
  }

  bool get hasDataIngestionApiUrl =>
      this.formValueMap.containsKey(DataIngestionApiUrlValueKey) &&
      (dataIngestionApiUrlValue?.isNotEmpty ?? false);
  bool get hasChunkSize =>
      this.formValueMap.containsKey(ChunkSizeValueKey) &&
      (chunkSizeValue?.isNotEmpty ?? false);
  bool get hasChunkOverlap =>
      this.formValueMap.containsKey(ChunkOverlapValueKey) &&
      (chunkOverlapValue?.isNotEmpty ?? false);
  bool get hasEmbeddingsApiUrl =>
      this.formValueMap.containsKey(EmbeddingsApiUrlValueKey) &&
      (embeddingsApiUrlValue?.isNotEmpty ?? false);
  bool get hasEmbeddingsApiKey =>
      this.formValueMap.containsKey(EmbeddingsApiKeyValueKey) &&
      (embeddingsApiKeyValue?.isNotEmpty ?? false);
  bool get hasEmbeddingsDimension =>
      this.formValueMap.containsKey(EmbeddingsDimensionValueKey) &&
      (embeddingsDimensionValue?.isNotEmpty ?? false);
  bool get hasEmbeddingsApiBatchSize =>
      this.formValueMap.containsKey(EmbeddingsApiBatchSizeValueKey) &&
      (embeddingsApiBatchSizeValue?.isNotEmpty ?? false);
  bool get hasSimilaritySearchType =>
      this.formValueMap.containsKey(SimilaritySearchTypeValueKey) &&
      (similaritySearchTypeValue?.isNotEmpty ?? false);
  bool get hasSimilaritySearchIndex =>
      this.formValueMap.containsKey(SimilaritySearchIndexValueKey) &&
      (similaritySearchIndexValue?.isNotEmpty ?? false);
  bool get hasRetrieveTopNResults =>
      this.formValueMap.containsKey(RetrieveTopNResultsValueKey) &&
      (retrieveTopNResultsValue?.isNotEmpty ?? false);
  bool get hasGenerationApiUrl =>
      this.formValueMap.containsKey(GenerationApiUrlValueKey) &&
      (generationApiUrlValue?.isNotEmpty ?? false);
  bool get hasGenerationApiKey =>
      this.formValueMap.containsKey(GenerationApiKeyValueKey) &&
      (generationApiKeyValue?.isNotEmpty ?? false);
  bool get hasPromptTemplate =>
      this.formValueMap.containsKey(PromptTemplateValueKey) &&
      (promptTemplateValue?.isNotEmpty ?? false);
  bool get hasTemperature =>
      this.formValueMap.containsKey(TemperatureValueKey) &&
      (temperatureValue?.isNotEmpty ?? false);
  bool get hasTopP =>
      this.formValueMap.containsKey(TopPValueKey) &&
      (topPValue?.isNotEmpty ?? false);
  bool get hasRepetitionPenalty =>
      this.formValueMap.containsKey(RepetitionPenaltyValueKey) &&
      (repetitionPenaltyValue?.isNotEmpty ?? false);
  bool get hasTopK =>
      this.formValueMap.containsKey(TopKValueKey) &&
      (topKValue?.isNotEmpty ?? false);
  bool get hasMaxNewTokens =>
      this.formValueMap.containsKey(MaxNewTokensValueKey) &&
      (maxNewTokensValue?.isNotEmpty ?? false);
  bool get hasStop =>
      this.formValueMap.containsKey(StopValueKey) &&
      (stopValue?.isNotEmpty ?? false);
  bool get hasStream =>
      this.formValueMap.containsKey(StreamValueKey) &&
      (streamValue?.isNotEmpty ?? false);

  bool get hasDataIngestionApiUrlValidationMessage =>
      this.fieldsValidationMessages[DataIngestionApiUrlValueKey]?.isNotEmpty ??
      false;
  bool get hasChunkSizeValidationMessage =>
      this.fieldsValidationMessages[ChunkSizeValueKey]?.isNotEmpty ?? false;
  bool get hasChunkOverlapValidationMessage =>
      this.fieldsValidationMessages[ChunkOverlapValueKey]?.isNotEmpty ?? false;
  bool get hasEmbeddingsApiUrlValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsApiUrlValueKey]?.isNotEmpty ??
      false;
  bool get hasEmbeddingsApiKeyValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsApiKeyValueKey]?.isNotEmpty ??
      false;
  bool get hasEmbeddingsDimensionValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsDimensionValueKey]?.isNotEmpty ??
      false;
  bool get hasEmbeddingsApiBatchSizeValidationMessage =>
      this
          .fieldsValidationMessages[EmbeddingsApiBatchSizeValueKey]
          ?.isNotEmpty ??
      false;
  bool get hasSimilaritySearchTypeValidationMessage =>
      this.fieldsValidationMessages[SimilaritySearchTypeValueKey]?.isNotEmpty ??
      false;
  bool get hasSimilaritySearchIndexValidationMessage =>
      this
          .fieldsValidationMessages[SimilaritySearchIndexValueKey]
          ?.isNotEmpty ??
      false;
  bool get hasRetrieveTopNResultsValidationMessage =>
      this.fieldsValidationMessages[RetrieveTopNResultsValueKey]?.isNotEmpty ??
      false;
  bool get hasGenerationApiUrlValidationMessage =>
      this.fieldsValidationMessages[GenerationApiUrlValueKey]?.isNotEmpty ??
      false;
  bool get hasGenerationApiKeyValidationMessage =>
      this.fieldsValidationMessages[GenerationApiKeyValueKey]?.isNotEmpty ??
      false;
  bool get hasPromptTemplateValidationMessage =>
      this.fieldsValidationMessages[PromptTemplateValueKey]?.isNotEmpty ??
      false;
  bool get hasTemperatureValidationMessage =>
      this.fieldsValidationMessages[TemperatureValueKey]?.isNotEmpty ?? false;
  bool get hasTopPValidationMessage =>
      this.fieldsValidationMessages[TopPValueKey]?.isNotEmpty ?? false;
  bool get hasRepetitionPenaltyValidationMessage =>
      this.fieldsValidationMessages[RepetitionPenaltyValueKey]?.isNotEmpty ??
      false;
  bool get hasTopKValidationMessage =>
      this.fieldsValidationMessages[TopKValueKey]?.isNotEmpty ?? false;
  bool get hasMaxNewTokensValidationMessage =>
      this.fieldsValidationMessages[MaxNewTokensValueKey]?.isNotEmpty ?? false;
  bool get hasStopValidationMessage =>
      this.fieldsValidationMessages[StopValueKey]?.isNotEmpty ?? false;
  bool get hasStreamValidationMessage =>
      this.fieldsValidationMessages[StreamValueKey]?.isNotEmpty ?? false;

  String? get dataIngestionApiUrlValidationMessage =>
      this.fieldsValidationMessages[DataIngestionApiUrlValueKey];
  String? get chunkSizeValidationMessage =>
      this.fieldsValidationMessages[ChunkSizeValueKey];
  String? get chunkOverlapValidationMessage =>
      this.fieldsValidationMessages[ChunkOverlapValueKey];
  String? get embeddingsApiUrlValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsApiUrlValueKey];
  String? get embeddingsApiKeyValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsApiKeyValueKey];
  String? get embeddingsDimensionValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsDimensionValueKey];
  String? get embeddingsApiBatchSizeValidationMessage =>
      this.fieldsValidationMessages[EmbeddingsApiBatchSizeValueKey];
  String? get similaritySearchTypeValidationMessage =>
      this.fieldsValidationMessages[SimilaritySearchTypeValueKey];
  String? get similaritySearchIndexValidationMessage =>
      this.fieldsValidationMessages[SimilaritySearchIndexValueKey];
  String? get retrieveTopNResultsValidationMessage =>
      this.fieldsValidationMessages[RetrieveTopNResultsValueKey];
  String? get generationApiUrlValidationMessage =>
      this.fieldsValidationMessages[GenerationApiUrlValueKey];
  String? get generationApiKeyValidationMessage =>
      this.fieldsValidationMessages[GenerationApiKeyValueKey];
  String? get promptTemplateValidationMessage =>
      this.fieldsValidationMessages[PromptTemplateValueKey];
  String? get temperatureValidationMessage =>
      this.fieldsValidationMessages[TemperatureValueKey];
  String? get topPValidationMessage =>
      this.fieldsValidationMessages[TopPValueKey];
  String? get repetitionPenaltyValidationMessage =>
      this.fieldsValidationMessages[RepetitionPenaltyValueKey];
  String? get topKValidationMessage =>
      this.fieldsValidationMessages[TopKValueKey];
  String? get maxNewTokensValidationMessage =>
      this.fieldsValidationMessages[MaxNewTokensValueKey];
  String? get stopValidationMessage =>
      this.fieldsValidationMessages[StopValueKey];
  String? get streamValidationMessage =>
      this.fieldsValidationMessages[StreamValueKey];
}

extension Methods on FormStateHelper {
  String? setDataIngestionApiUrlValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DataIngestionApiUrlValueKey] =
          validationMessage;
  String? setChunkSizeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[ChunkSizeValueKey] = validationMessage;
  String? setChunkOverlapValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[ChunkOverlapValueKey] = validationMessage;
  String? setEmbeddingsApiUrlValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmbeddingsApiUrlValueKey] =
          validationMessage;
  String? setEmbeddingsApiKeyValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmbeddingsApiKeyValueKey] =
          validationMessage;
  String? setEmbeddingsDimensionValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmbeddingsDimensionValueKey] =
          validationMessage;
  String? setEmbeddingsApiBatchSizeValidationMessage(
          String? validationMessage) =>
      this.fieldsValidationMessages[EmbeddingsApiBatchSizeValueKey] =
          validationMessage;
  String? setSimilaritySearchTypeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[SimilaritySearchTypeValueKey] =
          validationMessage;
  String? setSimilaritySearchIndexValidationMessage(
          String? validationMessage) =>
      this.fieldsValidationMessages[SimilaritySearchIndexValueKey] =
          validationMessage;
  String? setRetrieveTopNResultsValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[RetrieveTopNResultsValueKey] =
          validationMessage;
  String? setGenerationApiUrlValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[GenerationApiUrlValueKey] =
          validationMessage;
  String? setGenerationApiKeyValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[GenerationApiKeyValueKey] =
          validationMessage;
  String? setPromptTemplateValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PromptTemplateValueKey] = validationMessage;
  String? setTemperatureValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[TemperatureValueKey] = validationMessage;
  String? setTopPValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[TopPValueKey] = validationMessage;
  String? setRepetitionPenaltyValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[RepetitionPenaltyValueKey] =
          validationMessage;
  String? setTopKValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[TopKValueKey] = validationMessage;
  String? setMaxNewTokensValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[MaxNewTokensValueKey] = validationMessage;
  String? setStopValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[StopValueKey] = validationMessage;
  String? setStreamValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[StreamValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    dataIngestionApiUrlValue = '';
    chunkSizeValue = '';
    chunkOverlapValue = '';
    embeddingsApiUrlValue = '';
    embeddingsApiKeyValue = '';
    embeddingsDimensionValue = '';
    embeddingsApiBatchSizeValue = '';
    similaritySearchTypeValue = '';
    similaritySearchIndexValue = '';
    retrieveTopNResultsValue = '';
    generationApiUrlValue = '';
    generationApiKeyValue = '';
    promptTemplateValue = '';
    temperatureValue = '';
    topPValue = '';
    repetitionPenaltyValue = '';
    topKValue = '';
    maxNewTokensValue = '';
    stopValue = '';
    streamValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      DataIngestionApiUrlValueKey:
          getValidationMessage(DataIngestionApiUrlValueKey),
      ChunkSizeValueKey: getValidationMessage(ChunkSizeValueKey),
      ChunkOverlapValueKey: getValidationMessage(ChunkOverlapValueKey),
      EmbeddingsApiUrlValueKey: getValidationMessage(EmbeddingsApiUrlValueKey),
      EmbeddingsApiKeyValueKey: getValidationMessage(EmbeddingsApiKeyValueKey),
      EmbeddingsDimensionValueKey:
          getValidationMessage(EmbeddingsDimensionValueKey),
      EmbeddingsApiBatchSizeValueKey:
          getValidationMessage(EmbeddingsApiBatchSizeValueKey),
      SimilaritySearchTypeValueKey:
          getValidationMessage(SimilaritySearchTypeValueKey),
      SimilaritySearchIndexValueKey:
          getValidationMessage(SimilaritySearchIndexValueKey),
      RetrieveTopNResultsValueKey:
          getValidationMessage(RetrieveTopNResultsValueKey),
      GenerationApiUrlValueKey: getValidationMessage(GenerationApiUrlValueKey),
      GenerationApiKeyValueKey: getValidationMessage(GenerationApiKeyValueKey),
      PromptTemplateValueKey: getValidationMessage(PromptTemplateValueKey),
      TemperatureValueKey: getValidationMessage(TemperatureValueKey),
      TopPValueKey: getValidationMessage(TopPValueKey),
      RepetitionPenaltyValueKey:
          getValidationMessage(RepetitionPenaltyValueKey),
      TopKValueKey: getValidationMessage(TopKValueKey),
      MaxNewTokensValueKey: getValidationMessage(MaxNewTokensValueKey),
      StopValueKey: getValidationMessage(StopValueKey),
      StreamValueKey: getValidationMessage(StreamValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _SettingsViewTextValidations[key];
  if (validatorForKey == null) return null;

  final validationMessageForKey = validatorForKey(
    _SettingsViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      DataIngestionApiUrlValueKey:
          getValidationMessage(DataIngestionApiUrlValueKey),
      ChunkSizeValueKey: getValidationMessage(ChunkSizeValueKey),
      ChunkOverlapValueKey: getValidationMessage(ChunkOverlapValueKey),
      EmbeddingsApiUrlValueKey: getValidationMessage(EmbeddingsApiUrlValueKey),
      EmbeddingsApiKeyValueKey: getValidationMessage(EmbeddingsApiKeyValueKey),
      EmbeddingsDimensionValueKey:
          getValidationMessage(EmbeddingsDimensionValueKey),
      EmbeddingsApiBatchSizeValueKey:
          getValidationMessage(EmbeddingsApiBatchSizeValueKey),
      SimilaritySearchTypeValueKey:
          getValidationMessage(SimilaritySearchTypeValueKey),
      SimilaritySearchIndexValueKey:
          getValidationMessage(SimilaritySearchIndexValueKey),
      RetrieveTopNResultsValueKey:
          getValidationMessage(RetrieveTopNResultsValueKey),
      GenerationApiUrlValueKey: getValidationMessage(GenerationApiUrlValueKey),
      GenerationApiKeyValueKey: getValidationMessage(GenerationApiKeyValueKey),
      PromptTemplateValueKey: getValidationMessage(PromptTemplateValueKey),
      TemperatureValueKey: getValidationMessage(TemperatureValueKey),
      TopPValueKey: getValidationMessage(TopPValueKey),
      RepetitionPenaltyValueKey:
          getValidationMessage(RepetitionPenaltyValueKey),
      TopKValueKey: getValidationMessage(TopKValueKey),
      MaxNewTokensValueKey: getValidationMessage(MaxNewTokensValueKey),
      StopValueKey: getValidationMessage(StopValueKey),
      StreamValueKey: getValidationMessage(StreamValueKey),
    });
