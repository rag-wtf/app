import 'package:flutter/material.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:settings/src/ui/views/settings/settings_viewmodel.dart';
import 'package:ui/ui.dart';

class RetrievalSettingsWidget extends StatelessWidget {
  const RetrievalSettingsWidget({
    required this.isDense,
    required this.iconColor,
    required this.searchThresholdController,
    required this.retrieveTopNResultsController,
    required this.viewModel,
    super.key,
  });

  final bool isDense;
  final Color? iconColor;
  final TextEditingController searchThresholdController;
  final TextEditingController retrieveTopNResultsController;
  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          errorText: viewModel.searchThresholdValidationMessage,
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
          errorText: viewModel.retrieveTopNResultsValidationMessage,
          controller: retrieveTopNResultsController,
          textInputType: TextInputType.number,
        ),
      ],
    );
  }
}
