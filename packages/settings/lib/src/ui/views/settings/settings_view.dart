import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
import 'package:settings/src/ui/common/ui_helpers.dart';
import 'package:settings/src/ui/views/settings/settings_validators.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:settings/src/ui/widgets/generation_settings_widget.dart';
import 'package:settings/src/ui/widgets/indexing_settings_widget.dart';
import 'package:settings/src/ui/widgets/retrieval_settings_widget.dart';
import 'package:settings/src/ui/widgets/splitting_settings_widget.dart';
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
  SettingsView({
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
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
                        if (viewModel.llmProviderSelected != null) ...[
                          verticalSpaceTiny,
                          Link(
                            url: Uri.parse(
                              viewModel.llmProviderSelected!.website +
                                  defaultUtmParams,
                            ),
                            text: viewModel.llmProviderSelected!.website,
                            onUrlLaunched:
                                viewModel.analyticsFacade.trackUrlOpened,
                          ),
                          if (viewModel.llmProviderSelected!.litellm)
                            Link(
                              url: Uri.parse(
                                liteLlmWebsite + defaultUtmParams,
                              ),
                              text: liteLlmWebsite,
                              onUrlLaunched:
                                  viewModel.analyticsFacade.trackUrlOpened,
                            ),
                        ],
                      ],
                    ),
                  ),
                          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enabled Analytics',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              CheckboxOrSwitch(
                value: viewModel.analyticsEnabled,
                onChanged: (value) async {
                  await viewModel.setAnalyticsEnabled(value);
                },
              ),
            ],
          ),
        ),

                  ExpansionPanelList(
                    children: [
                      SimpleExpansionPanel(
                        headerText: 'Splitting',
                        body: SplittingSettingsWidget(
                          isDense: isDense,
                          viewModel: viewModel,
                          splitApiUrlController: splitApiUrlController,
                          chunkSizeController: chunkSizeController,
                          chunkOverlapController: chunkOverlapController,
                          iconColor: iconColor,
                        ),
                        isExpanded: viewModel.isPanelExpanded(0),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Indexing',
                        body: IndexingSettingsWidget(
                          iconColor: iconColor,
                          embeddingsModelController: embeddingsModelController,
                          embeddingModels: _getEmbeddingModels(viewModel),
                          isDense: isDense,
                          embeddingsModelContextLengthController:
                              embeddingsModelContextLengthController,
                          embeddingsApiUrlController:
                              embeddingsApiUrlController,
                          embeddingsApiKeyController:
                              embeddingsApiKeyController,
                          embeddingsApiBatchSizeController:
                              embeddingsApiBatchSizeController,
                          embeddingsDatabaseBatchSizeController:
                              embeddingsDatabaseBatchSizeController,
                          embeddingsDimensionsController:
                              embeddingsDimensionsController,
                          switchHorizontalPadding: switchHorizontalPadding,
                          viewModel: viewModel,
                        ),
                        isExpanded: viewModel.isPanelExpanded(1),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Retrieval',
                        body: RetrievalSettingsWidget(
                          isDense: isDense,
                          iconColor: iconColor,
                          searchThresholdController: searchThresholdController,
                          retrieveTopNResultsController:
                              retrieveTopNResultsController,
                          viewModel: viewModel,
                        ),
                        isExpanded: viewModel.isPanelExpanded(2),
                      ).build(context),
                      SimpleExpansionPanel(
                        headerText: 'Generation',
                        body: GenerationSettingsWidget(
                          iconColor: iconColor,
                          generationModelController: generationModelController,
                          generationModels: _getGenerationModels(viewModel),
                          isDense: isDense,
                          generationModelContextLengthController:
                              generationModelContextLengthController,
                          generationApiUrlController:
                              generationApiUrlController,
                          generationApiKeyController:
                              generationApiKeyController,
                          maxTokensController: maxTokensController,
                          temperatureController: temperatureController,
                          topPController: topPController,
                          stopController: stopController,
                          frequencyPenaltyController:
                              frequencyPenaltyController,
                          presencePenaltyController: presencePenaltyController,
                          switchHorizontalPadding: switchHorizontalPadding,
                          showSystemPromptDialogFunction:
                              showSystemPromptDialogFunction,
                          showPromptTemplateDialogFunction:
                              showPromptTemplateDialogFunction,
                          viewModel: viewModel,
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

  List<ChatModel>? _getGenerationModels(SettingsViewModel viewModel) {
    final generationModels =
        viewModel.llmProviderSelected?.chatCompletions.models;
    return generationModels;
  }

  List<EmbeddingModel>? _getEmbeddingModels(SettingsViewModel viewModel) {
    final embeddingModels = viewModel.llmProviderSelected?.embeddings.models;
    return embeddingModels;
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
