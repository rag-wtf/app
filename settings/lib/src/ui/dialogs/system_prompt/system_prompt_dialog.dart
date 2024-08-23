import 'package:database/database.dart';
import 'package:flutter/material.dart';
import 'package:settings/src/ui/common/app_colors.dart';
import 'package:settings/src/ui/common/ui_helpers.dart';
import 'package:settings/src/ui/dialogs/system_prompt/system_prompt_dialog.form.dart';
import 'package:settings/src/ui/dialogs/system_prompt/system_prompt_dialog_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@FormView(
  fields: [
    FormTextField(name: 'systemPrompt'),
  ],
)
class SystemPromptDialog extends StackedView<SystemPromptDialogModel>
    with $SystemPromptDialog {
  const SystemPromptDialog({
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
    SystemPromptDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
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
                  request.title ?? 'Edit System Prompt',
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
              labelText: 'System Prompt',
              textInputType: TextInputType.multiline,
              maxLines: 15,
              controller: systemPromptController,
              errorText: viewModel.systemPromptValidationMessage,
              showClearTextButton: false,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    completer(DialogResponse());
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
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
  SystemPromptDialogModel viewModelBuilder(BuildContext context) =>
      SystemPromptDialogModel(tablePrefix);

  @override
  Future<void> onViewModelReady(SystemPromptDialogModel viewModel) async {
    syncFormWithViewModel(viewModel);
    await viewModel.initialise();
  }

  @override
  void onDispose(SystemPromptDialogModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
