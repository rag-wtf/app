import 'package:analytics/src/app/app.dart';
import 'package:analytics/src/app/app.locator.dart';
import 'package:analytics/src/app/app.router.dart';
import 'package:analytics/src/services/analytics_facade.dart';
import 'package:analytics/src/services/logger_navigator_observer.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.registerSingletonAsync<AnalyticsFacade>(App.getAnalyticsFacade);
  await setupLocator();
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
        locator<LoggerNavigatorObserver>(),
      ],
    );
  }
}
