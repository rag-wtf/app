import 'package:database/src/services/model_repository.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.dart';
import 'package:database/src/ui/views/main/main_view.dart';
import 'package:database/src/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
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
    LazySingleton<Surreal>(classType: Surreal),
// @stacked-service
  ],
  dialogs: [
    StackedDialog(classType: ConnectionDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
