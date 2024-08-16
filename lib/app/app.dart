import 'package:archive/archive.dart';
import 'package:chat/chat.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rag/app/app.router.dart';
import 'package:rag/l10n/arb/app_localizations.dart';
import 'package:rag/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:rag/ui/views/home/home_view.dart';
import 'package:rag/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
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
    LazySingleton<StreamResponseService>(
      classType: HttpStreamResponseService,
      asType: StreamResponseService,
    ),

    // settings package
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),

    // database package
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
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: ConnectionDialog),
    StackedDialog(classType: EmbeddingDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.black54,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
    );

    return ThemeBuilder(
      darkTheme: darkTheme,
      lightTheme: lightTheme,
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
