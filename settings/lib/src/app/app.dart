// ignore_for_file: inference_failure_on_instance_creation

import 'package:settings/src/services/database_service.dart';
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
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SettingService),
    Singleton(
      classType: DatabaseService,
      asType: Surreal,
      resolveUsing: DatabaseService.getInstance,
    ),
// @stacked-service
    //LazySingleton(classType: SettingRepository),
  ],
  logger: StackedLogger(),
)
class App {}
