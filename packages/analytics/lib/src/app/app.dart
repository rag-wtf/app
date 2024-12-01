import 'package:analytics/src/services/analytics_facade.dart';
//import 'package:analytics/src/services/firebase_analytics_client.dart';
import 'package:analytics/src/services/logger_analytics_client.dart';
import 'package:analytics/src/services/logger_navigator_observer.dart';
import 'package:analytics/src/services/mixpanel_analytics_client.dart';
import 'package:analytics/src/ui/views/main/main_view.dart';
import 'package:analytics/src/ui/views/startup/startup_view.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: MainView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<LoggerNavigatorObserver>(classType: LoggerNavigatorObserver),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {
  static Future<AnalyticsFacade> getAnalyticsFacade() async {
    final mixpanelAnalyticsClient = await MixpanelAnalyticsClient.getInstance();
    return AnalyticsFacade([
      mixpanelAnalyticsClient,
      //FirebaseAnalyticsClient(),
      if (!kReleaseMode) LoggerAnalyticsClient(),
    ]);
  }
}
