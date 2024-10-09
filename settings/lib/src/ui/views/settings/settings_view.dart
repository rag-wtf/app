import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
import 'package:settings/src/ui/views/settings/settings_validators.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:ui/ui.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'splitApiUrl',
      validator: SettingsValidators.validateSplitApiUrl,
    ),
    FormTextField(
      name: 'chunkSize',
      validator: SettingsValidators.validateChunkSize,
    ),
    FormTextField(
      name: 'chunkOverlap',
      validator: SettingsValidators.validateChunkOverlap,
    ),
    FormTextField(name: 'embeddingsModel'),
    FormTextField(
      name: 'embeddingsModelContextLength',
      validator: SettingsValidators.validateEmbeddingsModelContextLength,
    ),
    FormTextField(
      name: 'embeddingsApiUrl',
      validator: SettingsValidators.validateEmbeddingsApiUrl,
    ),
    FormTextField(name: 'embeddingsApiKey'),
    FormTextField(
      name: 'embeddingsDimensions',
      validator: SettingsValidators.validateEmbeddingsDimensions,
    ),
    FormTextField(
      name: 'embeddingsApiBatchSize',
      validator: SettingsValidators.validateEmbeddingsBatchSize,
    ),
    FormTextField(
      name: 'embeddingsDatabaseBatchSize',
      validator: SettingsValidators.validateEmbeddingsBatchSize,
    ),
    FormTextField(
      name: 'searchType',
      validator: SettingsValidators.validateSearchType,
    ),
    FormTextField(
      name: 'searchIndex',
      validator: SettingsValidators.validateSearchIndex,
    ),
    FormTextField(
      name: 'searchThreshold',
      validator: SettingsValidators.validateSearchThreshold,
    ),
    FormTextField(
      name: 'retrieveTopNResults',
      validator: SettingsValidators.validateRetrieveTopNResults,
    ),
    FormTextField(name: 'generationModel'),
    FormTextField(
      name: 'generationModelContextLength',
      validator: SettingsValidators.validateGenerationModelContextLength,
    ),
    FormTextField(
      name: 'generationApiUrl',
      validator: SettingsValidators.validateGenerationApiUrl,
    ),
    FormTextField(name: 'generationApiKey'),
    FormTextField(
      name: 'temperature',
      validator: SettingsValidators.validateTemperature,
    ),
    FormTextField(
      name: 'topP',
      validator: SettingsValidators.validateTopP,
    ),
    FormTextField(
      name: 'frequencyPenalty',
      validator: SettingsValidators.validateFrequencyPenalty,
    ),
    FormTextField(
      name: 'presencePenalty',
      validator: SettingsValidators.validateFrequencyPenalty,
    ),    
    FormTextField(
      name: 'maxTokens',
      validator: SettingsValidators.validateMaxTokens,
    ),
    FormTextField(
      name: 'stop',
      validator: SettingsValidators.validateStop,
    ),
  ],
)
class SettingsView extends StackedView<SettingsViewModel> with $SettingsView {
  const SettingsView({
    required this.showSystemPromptDialogFunction,
    required this.showPromptTemplateDialogFunction,
    super.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
    this.redefineEmbeddingIndexFunction,
  });
  final String tablePrefix;
  final bool inPackage;
  final Future<String?> Function(
    String tablePrefix,
    String dimensions,
  )? redefineEmbeddingIndexFunction;
  final Future<void> Function() showSystemPromptDialogFunction;
  final Future<void> Function() showPromptTemplateDialogFunction;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    final iconColor = Theme.of(context).textTheme.displaySmall?.color;
    final isDense = MediaQuery.sizeOf(context).width < 600;
    final embeddingModels = viewModel.llmProviderSelected?.embeddings.models;
    final generationModels =
        viewModel.llmProviderSelected?.chatCompletions.models;
    final switchHorizontalPadding =
        MediaQuery.sizeOf(context).width < 600 ? 0.0 : 4.0;    
    return Scaffold(
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        isDense: isDense,
                        label: Text(
                          'LLM Provider',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      value: viewModel.llmProviderId,
                      items: viewModel.llmProviders.entries
                          .map(
                            (llmProviderEntry) => DropdownMenuItem(
                              value: llmProviderEntry.key,
                              child: Text(llmProviderEntry.value.name),
                            ),
                          )
                          .toList()
                        ..insert(
                          0,
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Select a LLM provider'),
                          ),
                        ),
                      onChanged: (value) async {
                        await viewModel.setLlmProvider(value!);
                      },
                    ),
                  ),
                  ExpansionPanelList(
                    children: [
                      SimpleExpansionPanel(
                        headerText: 'Splitting',
                        body: Column(
                          children: [
                            InputField(
                              isDense: isDense,
                              labelText: 'API URL',
                              prefixIcon: Icon(
                                Icons.http_outlined,
                                color: iconColor,
                              ),
                              hintText: 'https://www.example.com/split',
                              errorText: viewModel.splitApiUrlValidationMessage,
                              controller: splitApiUrlController,
                              textInputType: TextInputType.url,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Chunk Size',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '100 to 2000',
                              errorText: viewModel.chunkSizeValidationMessage,
                              controller: chunkSizeController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Chunk Overlap',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '10 to 400',
                              errorText:
                                  viewModel.chunkOverlapValidationMessage,
                              controller: chunkOverlapController,
                              textInputType: TextInputType.number,
                            ),
                          ],
                        ),
                        isExpanded: viewModel.isPanelExpanded(0),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Indexing',
                        body: Column(
                          children: [
                            InputFieldDropdown<EmbeddingModel>(
                              labelText: 'Model',
                              prefixIcon: Icon(
                                Icons.api_outlined,
                                color: iconColor,
                              ),
                              hintText: 'text-embedding-3-large',
                              errorText:
                                  viewModel.embeddingsModelValidationMessage,
                              controller: embeddingsModelController,
                              textInputType: TextInputType.text,
                              items: embeddingModels,
                              getItemValue: (model) => model.name,
                              getItemDisplayText: (model) => model.name,
                              onSelected: viewModel.onEmbeddingModelSelected,
                              defaultValue: embeddingModels?.firstWhere(
                                      (model) =>
                                          embeddingsModelController.text ==
                                          model.name,
                                      orElse: EmbeddingModel.nullObject,
                                    ),
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Context Length',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: defaultEmbeddingsModelContextLength,
                              errorText: viewModel
                                .embeddingsModelContextLengthValidationMessage,
                              controller:
                                  embeddingsModelContextLengthController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'API URL',
                              prefixIcon: Icon(
                                Icons.http_outlined,
                                color: iconColor,
                              ),
                              hintText: 'https://api.openai.com/v1/embeddings',
                              errorText:
                                  viewModel.embeddingsApiUrlValidationMessage,
                              controller: embeddingsApiUrlController,
                              textInputType: TextInputType.url,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'API Key',
                              prefixIcon: Icon(
                                Icons.key_outlined,
                                color: iconColor,
                              ),
                              hintText: '*' * 48,
                              errorText:
                                  viewModel.embeddingsApiKeyValidationMessage,
                              controller: embeddingsApiKeyController,
                              textInputType: TextInputType.none,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'API Batch Size',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '10 to 500',
                              errorText: viewModel
                                  .embeddingsApiBatchSizeValidationMessage,
                              controller: embeddingsApiBatchSizeController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Database Batch Size',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '10 to 500',
                              errorText: viewModel
                                  .embeddingsDatabaseBatchSizeValidationMessage,
                              controller: embeddingsDatabaseBatchSizeController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              readOnly: !viewModel.embeddingsDimensionsEnabled,
                              isDense: isDense,
                              labelText: 'Dimensions',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              suffixIcon: CheckboxOrSwitch(
                                value: viewModel.embeddingsDimensionsEnabled,
                                onChanged: (value) async {
                                  await viewModel
                                      .setEmbeddingsDimensionsEnabled(value);
                                },
                              ),
                              hintText: '256',
                              errorText: viewModel
                                  .embeddingsDimensionsValidationMessage,
                              controller: embeddingsDimensionsController,
                              textInputType: TextInputType.number,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: switchHorizontalPadding,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Compressed',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  CheckboxOrSwitch(
                                    value: viewModel.embeddingsCompressed,
                                    onChanged: (value) async {
                                      await viewModel
                                          .setEmbeddingsCompressed(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isExpanded: viewModel.isPanelExpanded(1),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Retrieval',
                        body: Column(
                          children: [
                            /* 
                            InputField( isDense: isDense,
                              labelText: 'Search Type',
                              prefixIcon: Icon(
                                Icons.search_outlined,
                                color: iconColor,
                              ),
                              errorText: viewModel.searchTypeValidationMessage,
                              controller: searchTypeController,
                              textInputType: TextInputType.text,
                            ),
                            */
                            InputField(
                              isDense: isDense,
                              labelText: 'Search Threshold',
                              prefixIcon: Icon(
                                Icons.manage_search_outlined,
                                color: iconColor,
                              ),
                              hintText: '0.5 to 0.9',
                              errorText:
                                  viewModel.searchThresholdValidationMessage,
                              controller: searchThresholdController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Top N',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '1 to 30',
                              errorText: viewModel
                                  .retrieveTopNResultsValidationMessage,
                              controller: retrieveTopNResultsController,
                              textInputType: TextInputType.number,
                            ),
                          ],
                        ),
                        isExpanded: viewModel.isPanelExpanded(2),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Generation',
                        body: Column(
                          children: [
                            InputFieldDropdown<ChatModel>(
                              labelText: 'Model',
                              prefixIcon: Icon(
                                Icons.api_outlined,
                                color: iconColor,
                              ),
                              hintText: 'gpt-4o-mini',
                              errorText:
                                  viewModel.generationModelValidationMessage,
                              controller: generationModelController,
                              textInputType: TextInputType.text,
                              items: generationModels,
                              getItemValue: (model) => model.name,
                              getItemDisplayText: (model) => model.name,
                              onSelected: viewModel.onGenerationModelSelected,
                              defaultValue: generationModels?.firstWhere(
                                      (model) =>
                                          generationModelController.text ==
                                          model.name,
                                      orElse: ChatModel.nullObject,
                                    ),
                            ),                         
                            InputField(
                              isDense: isDense,
                              labelText: 'Context Length',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: defaultGenerationModelContextLength,
                              errorText: viewModel
                                .generationModelContextLengthValidationMessage,
                              controller:
                                  generationModelContextLengthController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'API URL',
                              prefixIcon: Icon(
                                Icons.http_outlined,
                                color: iconColor,
                              ),
                              hintText:
                                  'https://api.openai.com/v1/chat/completions',
                              errorText:
                                  viewModel.generationApiUrlValidationMessage,
                              controller: generationApiUrlController,
                              textInputType: TextInputType.url,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'API Key',
                              prefixIcon: Icon(
                                Icons.key_outlined,
                                color: iconColor,
                              ),
                              hintText: '*' * 48,
                              errorText:
                                  viewModel.generationApiKeyValidationMessage,
                              controller: generationApiKeyController,
                              textInputType: TextInputType.none,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Max Tokens',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: 'Half of the Context Length',
                              errorText: viewModel.maxTokensValidationMessage,
                              controller: maxTokensController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Temperature',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '0 to 1',
                              errorText: viewModel.temperatureValidationMessage,
                              controller: temperatureController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Top P',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              hintText: '0 to 1',
                              errorText: viewModel.topPValidationMessage,
                              controller: topPController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              isDense: isDense,
                              labelText: 'Stop',
                              prefixIcon: Icon(
                                Icons.stop_circle_outlined,
                                color: iconColor,
                              ),
                              hintText: 'User,</s>',
                              errorText: viewModel.stopValidationMessage,
                              controller: stopController,
                              textInputType: TextInputType.text,
                            ),
                            InputField(
                              readOnly: !viewModel.frequencyPenaltyEnabled,
                              isDense: isDense,
                              labelText: 'Frequency Penalty',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              suffixIcon: CheckboxOrSwitch(
                                value: viewModel.frequencyPenaltyEnabled,
                                onChanged: (value) async {
                                  await viewModel
                                      .setFrequencyPenaltyEnabled(value);
                                },
                              ),
                              hintText: '-2 to 2',
                              errorText:
                                  viewModel.frequencyPenaltyValidationMessage,
                              controller: frequencyPenaltyController,
                              textInputType: TextInputType.number,
                            ),
                            InputField(
                              readOnly: !viewModel.presencePenaltyEnabled,
                              isDense: isDense,
                              labelText: 'Presence Penalty',
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
                                color: iconColor,
                              ),
                              suffixIcon: CheckboxOrSwitch(
                                value: viewModel.presencePenaltyEnabled,
                                onChanged: (value) async {
                                  await viewModel
                                      .setPresencePenaltyEnabled(value);
                                },
                              ),
                              hintText: '-2 to 2',
                              errorText:
                                  viewModel.presencePenaltyValidationMessage,
                              controller: presencePenaltyController,
                              textInputType: TextInputType.number,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: switchHorizontalPadding,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Streaming',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  CheckboxOrSwitch(
                                    value: viewModel.stream,
                                    onChanged: (value) async {
                                      await viewModel.setStream(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.edit_note_outlined,
                                color: iconColor,
                              ),
                              title: Text(
                                'Edit System Prompt',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onTap: showSystemPromptDialogFunction,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.edit_note_outlined,
                                color: iconColor,
                              ),
                              title: Text(
                                'Edit Prompt Template',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onTap: showPromptTemplateDialogFunction,
                            ),
                            
                          ],
                        ),
                        isExpanded: viewModel.isPanelExpanded(3),
                      ).build(context),
                    ],
                    expansionCallback: (panelIndex, isExpanded) {
                      viewModel.setPanelExpanded(
                        panelIndex,
                        isExpanded: isExpanded,
                      );
                    },
                    expandedHeaderPadding: EdgeInsets.zero,
                    elevation: 0,
                    materialGapSize: 0,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SettingsViewModel(
        tablePrefix,
        redefineEmbeddingIndexFunction,
        inPackage: inPackage,
      );

  @override
  Future<void> onViewModelReady(SettingsViewModel viewModel) async {
    syncFormWithViewModel(viewModel);
    await viewModel.initialise();
    splitApiUrlController.addListener(viewModel.setSplitApiUrl);
    chunkSizeController.addListener(viewModel.setChunkSize);
    chunkOverlapController.addListener(viewModel.setChunkOverlap);
    embeddingsModelController.addListener(viewModel.setEmbeddingsModel);
    embeddingsModelContextLengthController
        .addListener(viewModel.setEmbeddingsModelContextLength);
    embeddingsApiUrlController.addListener(viewModel.setEmbeddingsApiUrl);
    embeddingsApiKeyController.addListener(viewModel.setEmbeddingsApiKey);
    embeddingsDimensionsController
        .addListener(viewModel.setEmbeddingsDimensions);
    embeddingsApiBatchSizeController
        .addListener(viewModel.setEmbeddingsApiBatchSize);
    embeddingsDatabaseBatchSizeController
        .addListener(viewModel.setEmbeddingsDatabaseBatchSize);
    searchTypeController.addListener(viewModel.setSearchType);
    searchIndexController.addListener(viewModel.setSearchIndex);
    searchThresholdController.addListener(viewModel.setSearchThreshold);
    retrieveTopNResultsController.addListener(viewModel.setRetrieveTopNResults);
    generationModelController.addListener(viewModel.setGenerationModel);
    generationModelContextLengthController
        .addListener(viewModel.setGenerationModelContextLength);
    generationApiUrlController.addListener(viewModel.setGenerationApiUrl);
    generationApiKeyController.addListener(viewModel.setGenerationApiKey);
    temperatureController.addListener(viewModel.setTemperature);
    topPController.addListener(viewModel.setTopP);
    frequencyPenaltyController.addListener(viewModel.setFrequencyPenalty);
    presencePenaltyController.addListener(viewModel.setPresencePenalty);
    maxTokensController.addListener(viewModel.setMaxTokens);
    stopController.addListener(viewModel.setStop);
  }

  @override
  void onDispose(SettingsViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
