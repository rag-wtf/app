import 'package:flutter/material.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/llm_provider.dart';
import 'package:settings/src/ui/common/ui_helpers.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:ui/ui.dart';

class GenerationSettingsWidget extends StatelessWidget {
  const GenerationSettingsWidget({
    required this.iconColor,
    required this.generationModelController,
    required this.generationModels,
    required this.isDense,
    required this.generationModelContextLengthController,
    required this.generationApiUrlController,
    required this.generationApiKeyController,
    required this.maxTokensController,
    required this.temperatureController,
    required this.topPController,
    required this.stopController,
    required this.frequencyPenaltyController,
    required this.presencePenaltyController,
    required this.switchHorizontalPadding,
    required this.showSystemPromptDialogFunction,
    required this.showPromptTemplateDialogFunction,
    required this.viewModel,
    super.key,
  });

  final Color? iconColor;
  final TextEditingController generationModelController;
  final List<ChatModel>? generationModels;
  final bool isDense;
  final TextEditingController generationModelContextLengthController;
  final TextEditingController generationApiUrlController;
  final TextEditingController generationApiKeyController;
  final TextEditingController maxTokensController;
  final TextEditingController temperatureController;
  final TextEditingController topPController;
  final TextEditingController stopController;
  final TextEditingController frequencyPenaltyController;
  final TextEditingController presencePenaltyController;
  final double switchHorizontalPadding;
  final Future<void> Function() showSystemPromptDialogFunction;
  final Future<void> Function() showPromptTemplateDialogFunction;
  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final generationModelProvider =
        viewModel.llmProviderSelected?.chatCompletions;
    final modelLabel = generationModelProvider?.name != null
        ? 'Model of ${generationModelProvider?.name}'
        : 'Model';
    final generationModelApiKeyUrl = generationModelProvider?.apiKeyUrl ??
        viewModel.llmProviderSelected?.apiKeyUrl;      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputFieldDropdown<ChatModel>(
          labelText: modelLabel,
          prefixIcon: Icon(
            Icons.api_outlined,
            color: iconColor,
          ),
          hintText: 'gpt-4o-mini',
          errorText: viewModel.generationModelValidationMessage,
          controller: generationModelController,
          textInputType: TextInputType.text,
          items: generationModels,
          getItemValue: (model) => model.name,
          getItemDisplayText: (model) => model.name,
          onSelected: viewModel.onGenerationModelSelected,
          defaultValue: generationModels?.firstWhere(
            (model) => generationModelController.text == model.name,
            orElse: ChatModel.nullObject,
          ),
        ),
        if (generationModelProvider?.website != null) ...[
          Link(
            url: Uri.parse(
              generationModelProvider!.website! + defaultUtmParams,
            ),
            text: generationModelProvider.website!,
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
          hintText: defaultGenerationModelContextLength,
          errorText: viewModel.generationModelContextLengthValidationMessage,
          controller: generationModelContextLengthController,
          textInputType: TextInputType.number,
        ),
        InputField(
          isDense: isDense,
          labelText: 'API URL',
          prefixIcon: Icon(
            Icons.http_outlined,
            color: iconColor,
          ),
          hintText: 'https://api.openai.com/v1/chat/completions',
          errorText: viewModel.generationApiUrlValidationMessage,
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
          errorText: viewModel.generationApiKeyValidationMessage,
          controller: generationApiKeyController,
          textInputType: TextInputType.none,
        ),
        if (viewModel.llmProviderSelected != null &&
            generationModelApiKeyUrl != null)
          ...[
          Link(
            url: Uri.parse(
              generationModelApiKeyUrl + defaultUtmParams,
            ),
            text: getApiKeyText,
            onUrlLaunched: viewModel.analyticsFacade.trackUrlOpened,
          ),
          verticalSpaceTiny,
        ],        
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
              await viewModel.setFrequencyPenaltyEnabled(value);
            },
          ),
          hintText: '-2 to 2',
          errorText: viewModel.frequencyPenaltyValidationMessage,
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
              await viewModel.setPresencePenaltyEnabled(value);
            },
          ),
          hintText: '-2 to 2',
          errorText: viewModel.presencePenaltyValidationMessage,
          controller: presencePenaltyController,
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
                'Streaming',
                style: Theme.of(context).textTheme.titleSmall,
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
    );
  }
}
