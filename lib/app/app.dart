import 'package:flutter/material.dart';
import 'package:rag/app/app.router.dart';
import 'package:rag/l10n/l10n.dart';
import 'package:rag/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:rag/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:rag/ui/views/home/home_view.dart';
import 'package:rag/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton<BottomSheetService>(classType: BottomSheetService),
    LazySingleton<DialogService>(classType: DialogService),
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<DatabaseService>(
      classType: DatabaseService,
      asType: Surreal,
      resolveUsing: DatabaseService.getInstance,
    ),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
