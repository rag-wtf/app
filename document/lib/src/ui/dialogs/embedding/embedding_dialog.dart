import 'package:database/database.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/ui/common/ui_helpers.dart';
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
  });
  final DialogRequest<dynamic> request;
  final void Function(DialogResponse<void>) completer;

  @override
  Widget builder(
    BuildContext context,
    EmbeddingDialogModel viewModel,
    Widget? child,
  ) {
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
                  request.title ?? idController.text,
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
            verticalSpaceTiny,
            if (viewModel.isBusy)
              const Center(child: CircularProgressIndicator())
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: Expanded(
                  child: ListView(
                    children: [
                      /* InputField(
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
                      verticalSpaceTiny,
                      */
                      InputField(
                        labelText: 'Content',
                        errorText: viewModel.contentValidationMessage,
                        controller: contentController,
                        textInputType: TextInputType.text,
                        readOnly: true,
                        maxLines: 3,
                      ),
                      verticalSpaceTiny,
                      InputField(
                        labelText: 'Embedding',
                        errorText: viewModel.embeddingValidationMessage,
                        controller: embeddingController,
                        textInputType: TextInputType.text,
                        readOnly: true,
                      ),
                      verticalSpaceTiny,
                      InputField(
                        labelText: 'Metadata',
                        errorText: viewModel.metadataValidationMessage,
                        controller: metadataController,
                        textInputType: TextInputType.text,
                        readOnly: true,
                      ),
                      verticalSpaceTiny,
                      InputField(
                        labelText: 'Score',
                        errorText: viewModel.scoreValidationMessage,
                        controller: scoreController,
                        textInputType: TextInputType.number,
                        readOnly: true,
                      ),
                      verticalSpaceTiny,
                      InputField(
                        labelText: 'Created',
                        errorText: viewModel.createdValidationMessage,
                        controller: createdController,
                        textInputType: TextInputType.datetime,
                        readOnly: true,
                      ),
                      verticalSpaceTiny,
                      InputField(
                        labelText: 'Updated',
                        errorText: viewModel.updatedValidationMessage,
                        controller: updatedController,
                        textInputType: TextInputType.datetime,
                        readOnly: true,
                      ),
                    ],
                  ),
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
      EmbeddingDialogModel();

  @override
  Future<void> onViewModelReady(EmbeddingDialogModel viewModel) async {
    final embedding = request.data as Embedding;
    idController.text = embedding.id.toString();
    contentController.text = embedding.content;
    embeddingController.text = embedding.embedding.join(', ');
    metadataController.text = embedding.metadata.toString();
    createdController.text = embedding.created.toString();
    updatedController.text = embedding.updated.toString();
    if (embedding.score != null) {
      scoreController.text = embedding.score!.toStringAsFixed(2);
    }
  }
}
