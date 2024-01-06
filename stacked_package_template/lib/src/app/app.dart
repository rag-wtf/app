import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_package_template/src/services/model_repository.dart';
import 'package:stacked_package_template/src/ui/views/startup/startup_view.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:stacked_package_template/src/ui/views/main/main_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: MainView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<ModelRepository>(classType: ModelRepository),
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
