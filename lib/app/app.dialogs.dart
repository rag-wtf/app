// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/dialogs/info_alert/info_alert_dialog.dart';

enum DialogType {
  infoAlert,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = <DialogType, DialogBuilder>{
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
