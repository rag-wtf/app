import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:database/src/services/model_repository.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.dart';
import 'package:database/src/ui/views/main/main_view.dart';
import 'package:database/src/ui/views/startup/startup_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    LazySingleton<DialogService>(classType: DialogService),
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<ModelRepository>(classType: ModelRepository),
    LazySingleton<Surreal>(
      classType: SurrealWasm,
      asType: Surreal,
      resolveUsing: SurrealWasm.getInstance,
    ),
    LazySingleton<FlutterSecureStorage>(classType: FlutterSecureStorage),
    LazySingleton<ConnectionSettingRepository>(
      classType: ConnectionSettingRepository,
    ),
    LazySingleton<ConnectionSettingService>(
      classType: ConnectionSettingService,
    ),
// @stacked-service
  ],
  dialogs: [
    StackedDialog(classType: ConnectionDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
