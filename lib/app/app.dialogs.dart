// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/confirm_dialog.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.dart';
import 'package:document/src/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:settings/src/ui/dialogs/prompt_template/prompt_template_dialog.dart';
import 'package:settings/src/ui/dialogs/system_prompt/system_prompt_dialog.dart';

enum DialogType {
  infoAlert,
  connection,
  embedding,
  systemPrompt,
  promptTemplate,
  confirm,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
    DialogType.connection: (context, request, completer) =>
        ConnectionDialog(request: request, completer: completer),
    DialogType.embedding: (context, request, completer) =>
        EmbeddingDialog(request: request, completer: completer),
    DialogType.systemPrompt: (context, request, completer) =>
        SystemPromptDialog(request: request, completer: completer),
    DialogType.promptTemplate: (context, request, completer) =>
        PromptTemplateDialog(request: request, completer: completer),
    DialogType.confirm: (context, request, completer) =>
        ConfirmDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
