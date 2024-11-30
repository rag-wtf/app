import 'package:analytics/src/services/analytics_facade.dart';
import 'package:analytics/src/services/logger_analytics_client.dart';
import 'package:analytics/src/services/mixpanel_analytics_client.dart';
import 'package:analytics/src/services/model_repository.dart';
import 'package:analytics/src/ui/views/main/main_view.dart';
import 'package:analytics/src/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: MainView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<ModelRepository>(classType: ModelRepository),
    LazySingleton<Surreal>(
      classType: SurrealWasm,
      asType: Surreal,
      resolveUsing: SurrealWasm.getInstance,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {
    static Future<AnalyticsFacade> getAnalyticsFacade() async {
    final mixpanelAnalyticsClient = await MixpanelAnalyticsClient.getInstance();
    return AnalyticsFacade([
      LoggerAnalyticsClient(),
      mixpanelAnalyticsClient,
    ]);
  }
}
