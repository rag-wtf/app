// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/info_alert/info_alert_dialog.dart';

enum DialogType<T> {
  infoAlert,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, DialogRequest request, Completer<DialogResponse> completer) =>
        InfoAlertDialog<SheetRequest, SheetResponse>(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
