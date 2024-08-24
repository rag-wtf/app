import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_package_template/src/services/model_repository.dart';
import 'package:stacked_package_template/src/ui/views/main/main_view.dart';
import 'package:stacked_package_template/src/ui/views/startup/startup_view.dart';
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
      classType: SurrealWasmMutex,
      asType: Surreal,
      resolveUsing: SurrealWasmMutex.getInstance,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}

Surreal getInstance() {
  return Surreal({'engines': WasmEngine()});
}
