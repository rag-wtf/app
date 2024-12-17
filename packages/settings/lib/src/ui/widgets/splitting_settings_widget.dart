import 'package:flutter/material.dart';
import 'package:settings/src/info_text.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:ui/ui.dart';

class SplittingSettingsWidget extends StatelessWidget {
  const SplittingSettingsWidget({
    required this.isDense,
    required this.viewModel,
    required this.splitApiUrlController,
    required this.chunkSizeController,
    required this.chunkOverlapController,
    required this.iconColor,
    super.key,
  });
  final bool isDense;
  final SettingsViewModel viewModel;
  final TextEditingController splitApiUrlController;
  final TextEditingController chunkSizeController;
  final TextEditingController chunkOverlapController;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          isDense: isDense,
          labelText: 'API URL',
          helperText: splittingApiUrlInfoText,
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
          helperText: chunkSizeInfoText,
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
          helperText: chunkOverlapInfoText,
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
    );
  }
}
