import 'package:database/database.dart';
import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
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
    FormTextField(name: 'chunkSize'),
    FormTextField(name: 'chunkOverlap'),
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
    FormTextField(name: 'searchType'),
    FormTextField(name: 'searchIndex'),
    FormTextField(name: 'searchThreshold'),
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
    FormTextField(name: 'maxTokens'),
    FormTextField(name: 'stop'),
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
                          hintText: '100 to 1000',
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
                          hintText: '10 to 100',
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
                          hintText: 'gpt-3.5-turbo',
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
                          hintText: 'Half of the context windows',
                          errorText: viewModel.maxTokensValidationMessage,
                          controller: maxTokensController,
                          textInputType: TextInputType.number,
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
    topKController.addListener(viewModel.setTopK);
    maxTokensController.addListener(viewModel.setMaxTokens);
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
    } else {
      final uriString = uri.toString().toLowerCase();
      if (!(uriString.startsWith('http') || uriString.startsWith('https'))) {
        return 'The API URL must start with http or https.';
      }
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
      if (!uri!.path.endsWith(uriPath)) {
        return 'The API URL must be ended with $uriPath.';
      }
      return null;
    }
  }

  static String? validateSplitApiUrl(String? value) {
    return _validateApiUriPath(splitApiUriPath, value);
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

  static String? validateEmbeddingsDimensions(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (isPositiveInteger(value)) {
      final integer = int.parse(value);
      if (integer < 256) {
        return 'Please enter a minimum value of 256.';
      }
    } else {
      return 'Please enter a valid number';
    }

    return null;
  }
}
