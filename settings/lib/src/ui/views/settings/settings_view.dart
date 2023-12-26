import 'package:flutter/material.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:settings/src/ui/widgets/common/input_field.dart';
import 'package:settings/src/ui/widgets/settings/brightness_button.dart';
import 'package:settings/src/ui/widgets/settings/settings_expansion_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'dataIngestionApiUrl',
      validator: SettingsValidators.validateUrl,
    ),
    FormTextField(name: 'chunkSize'),
    FormTextField(name: 'chunkOverlap'),
    FormTextField(name: 'embeddingsApiUrl'),
    FormTextField(name: 'embeddingsApiKey'),
    FormTextField(name: 'embeddingsDimension'),
    FormTextField(
      name: 'embeddingsApiBatchSize',
      validator: SettingsValidators.validateEmbeddingsApiBatchSize,
    ),
    FormTextField(name: 'similaritySearchType'),
    FormTextField(name: 'similaritySearchIndex'),
    FormTextField(name: 'retrieveTopNResults'),
    FormTextField(name: 'generationApiUrl'),
    FormTextField(name: 'generationApiKey'),
    FormTextField(name: 'promptTemplate'),
    FormTextField(name: 'temperature'),
    FormTextField(name: 'topP'),
    FormTextField(name: 'repetitionPenalty'),
    FormTextField(name: 'topK'),
    FormTextField(name: 'maxNewTokens'),
    FormTextField(name: 'stop'),
    FormTextField(name: 'stream'),
  ],
)
class SettingsView extends StackedView<SettingsViewModel> with $SettingsView {
  const SettingsView(this.tablePrefix, {super.key});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          BrightnessButton(
            handleThemeModeChange: viewModel.handleThemeModeChange,
            showTooltipBelow: false,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          children: [
            SettingsExpansionPanel(
              headerText: 'data indexing',
              body: Column(
                children: [
                  ListTile(
                    title: const Text('API URL'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.https_outlined),
                      hintText: 'https://www.example.com/ingest',
                      errorText: viewModel.dataIngestionApiUrlValidationMessage,
                      controller: dataIngestionApiUrlController,
                      textInputType: TextInputType.url,
                    ),
                  ),
                  ListTile(
                    title: const Text('Chunk Size'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      hintText: 'Number between 100 and 1000',
                      errorText: viewModel.chunkSizeValidationMessage,
                      controller: chunkSizeController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                  ListTile(
                    title: const Text('Chunk Overlap'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      hintText: 'Number between 10 and 100',
                      errorText: viewModel.chunkOverlapValidationMessage,
                      controller: chunkOverlapController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              isExpanded: viewModel.isPanelExpanded(0),
            ).build(context),
            SettingsExpansionPanel(
              headerText: 'embeddings',
              body: Column(
                children: [
                  ListTile(
                    title: const Text('API URL'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.https_outlined),
                      hintText: 'https://www.example.com/embeddings',
                      errorText: viewModel.embeddingsApiUrlValidationMessage,
                      controller: embeddingsApiUrlController,
                      textInputType: TextInputType.url,
                    ),
                  ),
                  ListTile(
                    title: const Text('API Key'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.key_outlined),
                      errorText: viewModel.embeddingsApiKeyValidationMessage,
                      controller: embeddingsApiKeyController,
                      textInputType: TextInputType.none,
                    ),
                  ),
                  ListTile(
                    title: const Text('Dimension'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      errorText: viewModel.embeddingsDimensionValidationMessage,
                      controller: embeddingsDimensionController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                  ListTile(
                    title: const Text('Batch Size'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      hintText: 'Number between 10 and 500',
                      errorText:
                          viewModel.embeddingsApiBatchSizeValidationMessage,
                      controller: embeddingsApiBatchSizeController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              isExpanded: viewModel.isPanelExpanded(1),
            ).build(context),
            SettingsExpansionPanel(
              headerText: 'Retrieval',
              body: Column(
                children: [
                  ListTile(
                    title: const Text('Similarity Search'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.search_off_outlined),
                      errorText:
                          viewModel.similaritySearchTypeValidationMessage,
                      controller: similaritySearchTypeController,
                      textInputType: TextInputType.text,
                    ),
                  ),
                  ListTile(
                    title: const Text('Top N'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      hintText: 'Number between 1 and 30',
                      errorText: viewModel.retrieveTopNResultsValidationMessage,
                      controller: retrieveTopNResultsController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              isExpanded: viewModel.isPanelExpanded(2),
            ).build(context),
            SettingsExpansionPanel(
              headerText: 'generation',
              body: Column(
                children: [
                  ListTile(
                    title: const Text('API URL'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.https_outlined),
                      hintText: 'https://www.example.com/chat/completions',
                      errorText: viewModel.generationApiUrlValidationMessage,
                      controller: generationApiUrlController,
                      textInputType: TextInputType.url,
                    ),
                  ),
                  ListTile(
                    title: const Text('API Key'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.key_outlined),
                      errorText: viewModel.generationApiKeyValidationMessage,
                      controller: generationApiKeyController,
                      textInputType: TextInputType.none,
                    ),
                  ),
                  ListTile(
                    title: const Text('Max New Tokens'),
                    subtitle: InputField(
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      hintText: 'Half of the context windows',
                      errorText: viewModel.maxNewTokensValidationMessage,
                      controller: maxNewTokensController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              isExpanded: viewModel.isPanelExpanded(3),
            ).build(context),
          ],
          expansionCallback: (panelIndex, isExpanded) {
            viewModel.setPanelExpanded(panelIndex, isExpanded: isExpanded);
          },
          expandedHeaderPadding: EdgeInsets.zero,
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
  void onViewModelReady(SettingsViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    dataIngestionApiUrlController.addListener(viewModel.setDataIngestionApiUrl);

    embeddingsApiBatchSizeController
        .addListener(viewModel.setEmbeddingsApiBatchSize);
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
    } else if (uri.path != '/ingest') {
      return 'The API URL must end with /ingest.';
    }

    return null;
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
