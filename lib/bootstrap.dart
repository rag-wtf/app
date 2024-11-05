import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
// import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';
import 'package:stacked_themes/stacked_themes.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Add cross-flavor configuration here
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await ThemeManager.initialise();
  setupDialogUi();
  // setupBottomSheetUi();

  runApp(await builder());
}
