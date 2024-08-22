import 'package:database/database.dart';
import 'package:flutter/material.dart';
import 'package:settings/src/ui/views/settings/settings_validators.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:settings/src/ui/widgets/settings/settings_expansion_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

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
      validator: SettingsValidators.validateEmbeddingsApiBatchSize,
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
      name: 'generationApiUrl',
      validator: SettingsValidators.validateGenerationApiUrl,
    ),
    FormTextField(name: 'generationApiKey'),
    FormTextField(name: 'promptTemplate'),
    FormTextField(
      name: 'temperature',
      validator: SettingsValidators.validateTemperature,
    ),
    FormTextField(
      name: 'topP',
      validator: SettingsValidators.validateTopP,
    ),
    FormTextField(
      name: 'repetitionPenalty',
      validator: SettingsValidators.validateRepetitionPenalty,
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
    super.key,
    this.tablePrefix = 'main',
    this.hasConnectDatabase = false,
    this.redefineEmbeddingIndexFunction,
  });
  final String tablePrefix;
  final bool hasConnectDatabase;
  final Future<String?> Function(
    String tablePrefix,
    String dimensions,
  )? redefineEmbeddingIndexFunction;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    final iconColor = Theme.of(context).textTheme.displaySmall?.color;
    return Scaffold(
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ExpansionPanelList(
                children: [
                  SettingsExpansionPanel(
                    headerText: 'Splitting',
                    body: Column(
                      children: [
                        InputField(
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
                          labelText: 'Chunk Overlap',
                          prefixIcon: Icon(
                            Icons.numbers_outlined,
                            color: iconColor,
                          ),
                          hintText: '10 to 400',
                          errorText: viewModel.chunkOverlapValidationMessage,
                          controller: chunkOverlapController,
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                    isExpanded: viewModel.isPanelExpanded(0),
                  ).build(context),
                  SettingsExpansionPanel(
                    headerText: 'Indexing',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'Model',
                          prefixIcon: Icon(
                            Icons.api_outlined,
                            color: iconColor,
                          ),
                          hintText: 'text-embedding-3-large',
                          errorText: viewModel.embeddingsModelValidationMessage,
                          controller: embeddingsModelController,
                          textInputType: TextInputType.text,
                        ),
                        InputField(
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
                          labelText: 'API Key',
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: iconColor,
                          ),
                          hintText: '*' * 32,
                          errorText:
                              viewModel.embeddingsApiKeyValidationMessage,
                          controller: embeddingsApiKeyController,
                          textInputType: TextInputType.none,
                        ),
                        InputField(
                          labelText: 'Dimensions',
                          prefixIcon: Icon(
                            Icons.numbers_outlined,
                            color: iconColor,
                          ),
                          hintText: '256',
                          errorText:
                              viewModel.embeddingsDimensionsValidationMessage,
                          controller: embeddingsDimensionsController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
                          labelText: 'Batch Size',
                          prefixIcon: Icon(
                            Icons.numbers_outlined,
                            color: iconColor,
                          ),
                          hintText: '10 to 500',
                          errorText:
                              viewModel.embeddingsApiBatchSizeValidationMessage,
                          controller: embeddingsApiBatchSizeController,
                          textInputType: TextInputType.number,
                        ),
                        SwitchListTile(
                          title: Text(
                            'Compressed',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          value: viewModel.embeddingsCompressed,
                          onChanged: (value) async {
                            await viewModel.setEmbeddingsCompressed(value);
                          },
                        ),
                      ],
                    ),
                    isExpanded: viewModel.isPanelExpanded(1),
                  ).build(context),
                  SettingsExpansionPanel(
                    headerText: 'Retrieval',
                    body: Column(
                      children: [
                        /* 
                        InputField(
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
                          labelText: 'Search Threshold',
                          prefixIcon: Icon(
                            Icons.manage_search_outlined,
                            color: iconColor,
                          ),
                          hintText: '0.5 to 0.9',
                          errorText: viewModel.searchThresholdValidationMessage,
                          controller: searchThresholdController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
                          labelText: 'Top N',
                          prefixIcon: Icon(
                            Icons.numbers_outlined,
                            color: iconColor,
                          ),
                          hintText: '1 to 30',
                          errorText:
                              viewModel.retrieveTopNResultsValidationMessage,
                          controller: retrieveTopNResultsController,
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                    isExpanded: viewModel.isPanelExpanded(2),
                  ).build(context),
                  SettingsExpansionPanel(
                    headerText: 'Generation',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'Model',
                          prefixIcon: Icon(
                            Icons.api_outlined,
                            color: iconColor,
                          ),
                          hintText: 'gpt-4o-mini',
                          errorText: viewModel.generationModelValidationMessage,
                          controller: generationModelController,
                          textInputType: TextInputType.text,
                        ),
                        InputField(
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
                          labelText: 'API Key',
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: iconColor,
                          ),
                          hintText: '*' * 32,
                          errorText:
                              viewModel.generationApiKeyValidationMessage,
                          controller: generationApiKeyController,
                          textInputType: TextInputType.none,
                        ),
                        InputField(
                          labelText: 'Max Tokens',
                          prefixIcon: Icon(
                            Icons.numbers_outlined,
                            color: iconColor,
                          ),
                          hintText: 'Half the size of context windows',
                          errorText: viewModel.maxTokensValidationMessage,
                          controller: maxTokensController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
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
                          labelText: 'Repetition Penalty',
                          prefixIcon: Icon(
                            Icons.repeat,
                            color: iconColor,
                          ),
                          hintText: '-2 to 2',
                          errorText:
                              viewModel.repetitionPenaltyValidationMessage,
                          controller: repetitionPenaltyController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
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
                          labelText: 'Stop',
                          prefixIcon: Icon(
                            Icons.stop_outlined,
                            color: iconColor,
                          ),
                          hintText: 'User,</s>',
                          errorText: viewModel.stopValidationMessage,
                          controller: stopController,
                          textInputType: TextInputType.text,
                        ),
                        SwitchListTile(
                          title: Text(
                            'Streaming',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          value: viewModel.stream,
                          onChanged: (value) async {
                            await viewModel.setStream(value);
                          },
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
        hasConnectDatabase: hasConnectDatabase,
      );

  @override
  Future<void> onViewModelReady(SettingsViewModel viewModel) async {
    syncFormWithViewModel(viewModel);
    await viewModel.initialise();
    splitApiUrlController.addListener(viewModel.setSplitApiUrl);
    chunkSizeController.addListener(viewModel.setChunkSize);
    chunkOverlapController.addListener(viewModel.setChunkOverlap);
    embeddingsModelController.addListener(viewModel.setEmbeddingsModel);
    embeddingsApiUrlController.addListener(viewModel.setEmbeddingsApiUrl);
    embeddingsApiKeyController.addListener(viewModel.setEmbeddingsApiKey);
    embeddingsDimensionsController
        .addListener(viewModel.setEmbeddingsDimensions);
    embeddingsApiBatchSizeController
        .addListener(viewModel.setEmbeddingsApiBatchSize);
    searchTypeController.addListener(viewModel.setSearchType);
    searchIndexController.addListener(viewModel.setSearchIndex);
    searchThresholdController.addListener(viewModel.setSearchThreshold);
    retrieveTopNResultsController.addListener(viewModel.setRetrieveTopNResults);
    generationModelController.addListener(viewModel.setGenerationModel);
    generationApiUrlController.addListener(viewModel.setGenerationApiUrl);
    generationApiKeyController.addListener(viewModel.setGenerationApiKey);
    promptTemplateController.addListener(viewModel.setPromptTemplate);
    temperatureController.addListener(viewModel.setTemperature);
    topPController.addListener(viewModel.setTopP);
    repetitionPenaltyController.addListener(viewModel.setRepetitionPenalty);
    maxTokensController.addListener(viewModel.setMaxTokens);
    stopController.addListener(viewModel.setStop);
  }

  @override
  void onDispose(SettingsViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
