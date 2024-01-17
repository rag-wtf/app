import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:settings/src/ui/widgets/common/input_field.dart';
import 'package:settings/src/ui/widgets/settings/settings_expansion_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'dataIngestionApiUrl',
      validator: SettingsValidators.validateDataIngestionApiUrl,
    ),
    FormTextField(name: 'chunkSize'),
    FormTextField(name: 'chunkOverlap'),
    FormTextField(name: 'embeddingsModel'),
    FormTextField(
      name: 'embeddingsApiUrl',
      validator: SettingsValidators.validateEmbeddingsApiUrl,
    ),
    FormTextField(name: 'embeddingsApiKey'),
    FormTextField(name: 'embeddingsDimension'),
    FormTextField(
      name: 'embeddingsApiBatchSize',
      validator: SettingsValidators.validateEmbeddingsApiBatchSize,
    ),
    FormTextField(name: 'similaritySearchType'),
    FormTextField(name: 'similaritySearchIndex'),
    FormTextField(name: 'retrieveTopNResults'),
    FormTextField(name: 'generationModel'),
    FormTextField(
      name: 'generationApiUrl',
      validator: SettingsValidators.validateGenerationApiUrl,
    ),
    FormTextField(name: 'generationApiKey'),
    FormTextField(name: 'promptTemplate'),
    FormTextField(name: 'temperature'),
    FormTextField(name: 'topP'),
    FormTextField(name: 'repetitionPenalty'),
    FormTextField(name: 'topK'),
    FormTextField(name: 'maxNewTokens'),
    FormTextField(name: 'stop'),
  ],
)
class SettingsView extends StackedView<SettingsViewModel> with $SettingsView {
  const SettingsView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ExpansionPanelList(
                children: [
                  SettingsExpansionPanel(
                    headerText: 'splitting',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'API URL',
                          prefixIcon: const Icon(Icons.https_outlined),
                          hintText: 'https://www.example.com/ingest',
                          errorText:
                              viewModel.dataIngestionApiUrlValidationMessage,
                          controller: dataIngestionApiUrlController,
                          textInputType: TextInputType.url,
                        ),
                        InputField(
                          labelText: 'Chunk Size',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          hintText: 'between 100 and 1000',
                          errorText: viewModel.chunkSizeValidationMessage,
                          controller: chunkSizeController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
                          labelText: 'Chunk Overlap',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          hintText: 'between 10 and 100',
                          errorText: viewModel.chunkOverlapValidationMessage,
                          controller: chunkOverlapController,
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                    isExpanded: viewModel.isPanelExpanded(0),
                  ).build(context),
                  SettingsExpansionPanel(
                    headerText: 'indexing',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'Model',
                          prefixIcon: const Icon(Icons.model_training_outlined),
                          hintText: 'text-embedding-ada-002',
                          errorText: viewModel.embeddingsModelValidationMessage,
                          controller: embeddingsModelController,
                          textInputType: TextInputType.text,
                        ),
                        InputField(
                          labelText: 'API URL',
                          prefixIcon: const Icon(Icons.https_outlined),
                          hintText: 'https://api.openai.com/v1/embeddings',
                          errorText:
                              viewModel.embeddingsApiUrlValidationMessage,
                          controller: embeddingsApiUrlController,
                          textInputType: TextInputType.url,
                        ),
                        InputField(
                          labelText: 'API Key',
                          prefixIcon: const Icon(Icons.key_outlined),
                          hintText: '*' * 32,
                          errorText:
                              viewModel.embeddingsApiKeyValidationMessage,
                          controller: embeddingsApiKeyController,
                          textInputType: TextInputType.none,
                        ),
                        InputField(
                          labelText: 'Dimension',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          errorText:
                              viewModel.embeddingsDimensionValidationMessage,
                          controller: embeddingsDimensionController,
                          textInputType: TextInputType.number,
                        ),
                        InputField(
                          labelText: 'Batch Size',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          hintText: 'between 10 and 500',
                          errorText:
                              viewModel.embeddingsApiBatchSizeValidationMessage,
                          controller: embeddingsApiBatchSizeController,
                          textInputType: TextInputType.number,
                        ),
                      ],
                    ),
                    isExpanded: viewModel.isPanelExpanded(1),
                  ).build(context),
                  SettingsExpansionPanel(
                    headerText: 'Retrieval',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'Similarity Search',
                          prefixIcon: const Icon(Icons.search_off_outlined),
                          errorText:
                              viewModel.similaritySearchTypeValidationMessage,
                          controller: similaritySearchTypeController,
                          textInputType: TextInputType.text,
                        ),
                        InputField(
                          labelText: 'Top N',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          hintText: 'between 1 and 30',
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
                    headerText: 'generation',
                    body: Column(
                      children: [
                        InputField(
                          labelText: 'Model',
                          prefixIcon: const Icon(Icons.model_training_outlined),
                          hintText: 'gpt-3.5-turbo',
                          errorText: viewModel.generationModelValidationMessage,
                          controller: generationModelController,
                          textInputType: TextInputType.text,
                        ),
                        InputField(
                          labelText: 'API URL',
                          prefixIcon: const Icon(Icons.https_outlined),
                          hintText:
                              'https://api.openai.com/v1/chat/completions',
                          errorText:
                              viewModel.generationApiUrlValidationMessage,
                          controller: generationApiUrlController,
                          textInputType: TextInputType.url,
                        ),
                        InputField(
                          labelText: 'API Key',
                          prefixIcon: const Icon(Icons.key_outlined),
                          hintText: '*' * 32,
                          errorText:
                              viewModel.generationApiKeyValidationMessage,
                          controller: generationApiKeyController,
                          textInputType: TextInputType.none,
                        ),
                        InputField(
                          labelText: 'Max New Tokens',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                          hintText: 'Half of the context windows',
                          errorText: viewModel.maxNewTokensValidationMessage,
                          controller: maxNewTokensController,
                          textInputType: TextInputType.number,
                        ),
                        SwitchListTile(
                          title: const Text('Streaming'),
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
      SettingsViewModel(tablePrefix);

  @override
  Future<void> onViewModelReady(SettingsViewModel viewModel) async {
    syncFormWithViewModel(viewModel);
    dataIngestionApiUrlController.addListener(viewModel.setDataIngestionApiUrl);
    chunkSizeController.addListener(viewModel.setChunkSize);
    chunkOverlapController.addListener(viewModel.setChunkOverlap);
    embeddingsModelController.addListener(viewModel.setEmbeddingsModel);
    embeddingsApiUrlController.addListener(viewModel.setEmbeddingsApiUrl);
    embeddingsApiKeyController.addListener(viewModel.setEmbeddingsApiKey);
    embeddingsDimensionController.addListener(viewModel.setEmbeddingsDimension);
    embeddingsApiBatchSizeController
        .addListener(viewModel.setEmbeddingsApiBatchSize);
    similaritySearchTypeController
        .addListener(viewModel.setSimilaritySearchType);
    similaritySearchIndexController
        .addListener(viewModel.setSimilaritySearchIndex);
    retrieveTopNResultsController.addListener(viewModel.setRetrieveTopNResults);
    generationModelController.addListener(viewModel.setGenerationModel);
    generationApiUrlController.addListener(viewModel.setGenerationApiUrl);
    generationApiKeyController.addListener(viewModel.setGenerationApiKey);
    promptTemplateController.addListener(viewModel.setPromptTemplate);
    temperatureController.addListener(viewModel.setTemperature);
    topPController.addListener(viewModel.setTopP);
    repetitionPenaltyController.addListener(viewModel.setRepetitionPenalty);
    topKController.addListener(viewModel.setTopK);
    maxNewTokensController.addListener(viewModel.setMaxNewTokens);
    stopController.addListener(viewModel.setStop);
  }

  @override
  void onDispose(SettingsViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}

class SettingsValidators {
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      return 'Enter a valid URL';
    } else if (!uri.isScheme('HTTPS')) {
      return 'The API URL must start with https.';
    }

    return null;
  }

  static String? _validateApiUriPath(String uriPath, String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final message = validateUrl(value);
    if (message != null) {
      return message;
    } else {
      final uri = Uri.tryParse(value);
      if (uri!.path.endsWith(uriPath)) {
        return 'The API URL must be ended with $uriPath.';
      }
      return null;
    }
  }

  static String? validateDataIngestionApiUrl(String? value) {
    return _validateApiUriPath(dataIngestionApiUriPath, value);
  }

  static String? validateEmbeddingsApiUrl(String? value) {
    return _validateApiUriPath(embeddingsApiUriPath, value);
  }

  static String? validateGenerationApiUrl(String? value) {
    return _validateApiUriPath(generationApiUriPath, value);
  }

  static bool isPositiveInteger(String s) {
    return RegExp(r'^[0-9]+$').hasMatch(s);
  }

  static String? validateEmbeddingsApiBatchSize(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (isPositiveInteger(value)) {
      final integer = int.parse(value);
      if (integer < 10 || integer > 500) {
        return 'Enter number between 10 and 500.';
      }
    } else {
      return 'Enter a valid number';
    }

    return null;
  }
}
