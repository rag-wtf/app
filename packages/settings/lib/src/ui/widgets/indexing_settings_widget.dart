import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
import 'package:settings/src/ui/common/ui_helpers.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:ui/ui.dart';

class IndexingSettingsWidget extends StatelessWidget {
  const IndexingSettingsWidget({
    required this.iconColor,
    required this.embeddingsModelController,
    required this.embeddingModels,
    required this.isDense,
    required this.embeddingsModelContextLengthController,
    required this.embeddingsApiUrlController,
    required this.embeddingsApiKeyController,
    required this.embeddingsApiBatchSizeController,
    required this.embeddingsDatabaseBatchSizeController,
    required this.embeddingsDimensionsController,
    required this.switchHorizontalPadding,
    required this.viewModel,
    super.key,
  });

  final Color? iconColor;
  final TextEditingController embeddingsModelController;
  final List<EmbeddingModel>? embeddingModels;
  final bool isDense;
  final TextEditingController embeddingsModelContextLengthController;
  final TextEditingController embeddingsApiUrlController;
  final TextEditingController embeddingsApiKeyController;
  final TextEditingController embeddingsApiBatchSizeController;
  final TextEditingController embeddingsDatabaseBatchSizeController;
  final TextEditingController embeddingsDimensionsController;
  final double switchHorizontalPadding;
  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final embeddingModelProvider = viewModel.llmProviderSelected?.embeddings;
    final modelLabel = embeddingModelProvider?.name != null
        ? 'Model of ${embeddingModelProvider?.name}'
        : 'Model';
    final embeddingModelApiKeyUrl = embeddingModelProvider?.apiKeyUrl ?? 
        viewModel.llmProviderSelected?.apiKeyUrl;    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputFieldDropdown<EmbeddingModel>(
          labelText: modelLabel,
          prefixIcon: Icon(
            Icons.api_outlined,
            color: iconColor,
          ),
          hintText: 'text-embedding-3-large',
          errorText: viewModel.embeddingsModelValidationMessage,
          controller: embeddingsModelController,
          textInputType: TextInputType.text,
          items: embeddingModels,
          getItemValue: (model) => model.name,
          getItemDisplayText: (model) => model.name,
          onSelected: viewModel.onEmbeddingModelSelected,
          defaultValue: embeddingModels?.firstWhere(
            (model) => embeddingsModelController.text == model.name,
            orElse: EmbeddingModel.nullObject,
          ),
        ),
        if (embeddingModelProvider?.website != null) ...[
          Link(
            url: Uri.parse(
              embeddingModelProvider!.website! + defaultUtmParams,
            ),
            text: embeddingModelProvider.website!,
            onUrlLaunched: viewModel.analyticsFacade.trackUrlOpened,
          ),
          verticalSpaceTiny,
        ],
        InputField(
          isDense: isDense,
          labelText: 'Context Length',
          prefixIcon: Icon(
            Icons.numbers_outlined,
            color: iconColor,
          ),
          hintText: defaultEmbeddingsModelContextLength,
          errorText: viewModel.embeddingsModelContextLengthValidationMessage,
          controller: embeddingsModelContextLengthController,
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
          errorText: viewModel.embeddingsApiUrlValidationMessage,
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
          errorText: viewModel.embeddingsApiKeyValidationMessage,
          controller: embeddingsApiKeyController,
          textInputType: TextInputType.none,
        ),
        if (viewModel.llmProviderSelected != null &&
            embeddingModelApiKeyUrl != null) ...[
          Link(
            url: Uri.parse(
              embeddingModelApiKeyUrl + defaultUtmParams,
            ),
            text: getApiKeyText,
            onUrlLaunched: viewModel.analyticsFacade.trackUrlOpened,
          ),
          verticalSpaceTiny,
        ],
        InputField(
          isDense: isDense,
          labelText: 'API Batch Size',
          prefixIcon: Icon(
            Icons.numbers_outlined,
            color: iconColor,
          ),
          hintText: '10 to 500',
          errorText: viewModel.embeddingsApiBatchSizeValidationMessage,
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
          errorText: viewModel.embeddingsDatabaseBatchSizeValidationMessage,
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
              await viewModel.setEmbeddingsDimensionsEnabled(value);
            },
          ),
          hintText: '256',
          errorText: viewModel.embeddingsDimensionsValidationMessage,
          controller: embeddingsDimensionsController,
          textInputType: TextInputType.number,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: switchHorizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compressed',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              CheckboxOrSwitch(
                value: viewModel.embeddingsCompressed,
                onChanged: (value) async {
                  await viewModel.setEmbeddingsCompressed(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
