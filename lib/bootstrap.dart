import 'dart:async';
import 'dart:developer';
import 'package:env_reader/env_reader.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Add cross-flavor configuration here
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load(
    EnvStringLoader(
      await rootBundle.loadString('assets/env/.env'),
    ),
    'qzG[?My3<xF.f_rkZ]D^~b',
  );

  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  runApp(await builder());
}
