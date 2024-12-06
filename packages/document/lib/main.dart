import 'package:document/src/app/app.dialogs.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'src/ui/views/startup/hello.dart';
import 'src/ui/views/startup/hello.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
