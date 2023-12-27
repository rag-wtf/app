import 'package:document/src/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    Singleton(
      classType: DatabaseService,
      asType: Surreal,
      resolveUsing: DatabaseService.getInstance,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
