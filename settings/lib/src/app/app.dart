import 'package:settings/src/services/app_setting_service.dart';
import 'package:settings/src/services/database_service.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/views/settings/settings_view.dart';
import 'package:settings/src/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: SettingsView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<AppSettingService>(classType: AppSettingService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
