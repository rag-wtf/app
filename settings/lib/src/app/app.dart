import 'package:database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/dialogs/prompt_template/prompt_template_dialog.dart';
import 'package:settings/src/ui/dialogs/system_prompt/system_prompt_dialog.dart';
import 'package:settings/src/ui/views/settings/settings_view.dart';
import 'package:settings/src/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: SettingsView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<DialogService>(classType: DialogService),
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),

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
    StackedDialog(classType: SystemPromptDialog),
    StackedDialog(classType: PromptTemplateDialog),
// @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
