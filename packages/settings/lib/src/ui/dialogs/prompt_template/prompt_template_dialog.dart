import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:settings/src/ui/common/app_colors.dart';
import 'package:settings/src/ui/common/ui_helpers.dart';
import 'package:settings/src/ui/dialogs/prompt_template/prompt_template_dialog.form.dart';
import 'package:settings/src/ui/dialogs/prompt_template/prompt_template_dialog_model.dart';
import 'package:settings/src/ui/views/settings/settings_validators.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:ui/ui.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'promptTemplate',
      validator: SettingsValidators.validatePromptTemplate,
    ),
  ],
)
class PromptTemplateDialog extends StackedView<PromptTemplateDialogModel>
    with $PromptTemplateDialog {
  const PromptTemplateDialog({
    required this.request,
    required this.completer,
    this.tablePrefix = 'main',
    super.key,
  });

  final DialogRequest<void> request;
  final void Function(DialogResponse<void>) completer;
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    PromptTemplateDialogModel viewModel,
    Widget? child,
  ) {
    return AdaptiveDialog(
      maxWidth: dialogMaxWidth,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.title ?? 'Edit Prompt Template',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => completer(DialogResponse()),
                ),
              ],
            ),
            if (request.description != null) ...[
              verticalSpaceTiny,
              Text(
                request.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: kcMediumGrey,
                ),
                maxLines: 3,
                softWrap: true,
              ),
            ],
            verticalSpaceMedium,
            InputField(
              labelText: 'Prompt Template',
              textInputType: TextInputType.multiline,
              maxLines: 15,
              controller: promptTemplateController,
              errorText: viewModel.promptTemplateValidationMessage,
              showClearTextButton: false,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    completer(DialogResponse());
                  },
                  child: const Text('Cancel'),
                ),
                horizontalSpaceSmall,
                ElevatedButton(
                  onPressed: viewModel.hasAnyValidationMessage
                      ? null
                      : () async {
                          await viewModel.save();
                          completer(DialogResponse(confirmed: true));
                        },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  PromptTemplateDialogModel viewModelBuilder(BuildContext context) =>
      PromptTemplateDialogModel(tablePrefix);

  @override
  Future<void> onViewModelReady(PromptTemplateDialogModel viewModel) async {
    syncFormWithViewModel(viewModel);
    await viewModel.initialise();
  }

  @override
  void onDispose(PromptTemplateDialogModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
