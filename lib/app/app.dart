import 'package:archive/archive.dart';
import 'package:chat/chat.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:rag/app/app.router.dart';
import 'package:rag/l10n/arb/app_localizations.dart';
import 'package:rag/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:rag/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:rag/ui/views/home/home_view.dart';
import 'package:rag/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
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
    // document package
    Factory(classType: Dio),
    LazySingleton<DocumentApiService>(classType: DocumentApiService),
    LazySingleton<GZipEncoder>(classType: GZipEncoder),
    LazySingleton<GZipDecoder>(classType: GZipDecoder),
    LazySingleton<DocumentService>(classType: DocumentService),
    LazySingleton<DocumentRepository>(classType: DocumentRepository),
    LazySingleton<EmbeddingRepository>(classType: EmbeddingRepository),
    LazySingleton<DocumentEmbeddingRepository>(
      classType: DocumentEmbeddingRepository,
    ),
    LazySingleton<BatchService>(classType: BatchService),

    // chat package
    LazySingleton<ChatRepository>(classType: ChatRepository),
    LazySingleton<ChatMessageRepository>(
      classType: ChatMessageRepository,
    ),
    LazySingleton<MessageRepository>(classType: MessageRepository),
    LazySingleton<MessageEmbeddingRepository>(
      classType: MessageEmbeddingRepository,
    ),
    LazySingleton<ChatService>(classType: ChatService),
    LazySingleton<ChatApiService>(classType: ChatApiService),

    // settings package
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
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
    return ThemeBuilder(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          surface: Colors.black87,
          brightness: Brightness.dark,
          secondary: Colors.lightBlue[700],
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
      ),
      lightTheme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          surface: Colors.white70,
          brightness: Brightness.light,
          secondary: Colors.blue[700],
        ),
      ),
      statusBarColorBuilder: (theme) => theme?.colorScheme.secondary,
      navigationBarColorBuilder: (theme) => theme?.colorScheme.secondary,
      builder: (context, regularTheme, darkTheme, themeMode) => MaterialApp(
        title: appTitle,
        theme: regularTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: Routes.startupView,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
      ),
    );
  }
}
