// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.dart';
import 'package:document/src/ui/dialogs/info_alert/info_alert_dialog.dart';

enum DialogType {
  infoAlert,
  connection,
  embedding,
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
  };

  dialogService.registerCustomDialogBuilders(builders);
}
