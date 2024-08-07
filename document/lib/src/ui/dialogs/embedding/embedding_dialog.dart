import 'package:database/database.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.form.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@FormView(
  fields: [
    FormTextField(name: 'id'),
    FormTextField(name: 'content'),
    FormTextField(name: 'embedding'),
    FormTextField(name: 'metadata'),
    FormTextField(name: 'created'),
    FormTextField(name: 'updated'),
    FormTextField(name: 'score'),
  ],
)
class EmbeddingDialog extends StackedView<EmbeddingDialogModel>
    with $EmbeddingDialog {
  const EmbeddingDialog({
    required this.request,
    required this.completer,
    super.key,
    this.tablePrefix = 'main',
  });
  final DialogRequest<dynamic> request;
  final void Function(DialogResponse<void>) completer;
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    EmbeddingDialogModel viewModel,
    Widget? child,
  ) {
    final iconColor = Theme.of(context).textTheme.displaySmall?.color;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.title ?? 'Chunk',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => completer(DialogResponse(confirmed: true)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (viewModel.isBusy)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: [
                    InputField(
                      labelText: 'ID',
                      prefixIcon: Icon(
                        Icons.fingerprint,
                        color: iconColor,
                      ),
                      errorText: viewModel.idValidationMessage,
                      controller: idController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Content',
                      prefixIcon: Icon(
                        Icons.text_snippet_outlined,
                        color: iconColor,
                      ),
                      errorText: viewModel.contentValidationMessage,
                      controller: contentController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Embedding',
                      prefixIcon: Icon(
                        Icons.graphic_eq_outlined,
                        color: iconColor,
                      ),
                      errorText: viewModel.embeddingValidationMessage,
                      controller: embeddingController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                      //minLines: 1,
                      //maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Metadata',
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: iconColor,
                      ),
                      errorText: viewModel.metadataValidationMessage,
                      controller: metadataController,
                      textInputType: TextInputType.text,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Created',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: iconColor,
                      ),
                      errorText: viewModel.createdValidationMessage,
                      controller: createdController,
                      textInputType: TextInputType.datetime,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Updated',
                      prefixIcon: Icon(
                        Icons.update_outlined,
                        color: iconColor,
                      ),
                      errorText: viewModel.updatedValidationMessage,
                      controller: updatedController,
                      textInputType: TextInputType.datetime,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      labelText: 'Score',
                      prefixIcon: Icon(
                        Icons.score_outlined,
                        color: iconColor,
                      ),
                      errorText: viewModel.scoreValidationMessage,
                      controller: scoreController,
                      textInputType: TextInputType.number,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  EmbeddingDialogModel viewModelBuilder(
    BuildContext context,
  ) =>
      EmbeddingDialogModel(tablePrefix);

  @override
  Future<void> onViewModelReady(EmbeddingDialogModel viewModel) async {
    await viewModel.initialise(request.data as Embedding);
    syncFormWithViewModel(viewModel);
  }
}
