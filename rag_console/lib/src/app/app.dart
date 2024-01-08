import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:rag_console/src/ui/views/rag_console/rag_console_view.dart';
import 'package:rag_console/src/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:rag_console/src/services/rag_console_api_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: RagConsoleView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),

    // document package
    LazySingleton<Dio>(classType: Dio),
    LazySingleton<DocumentApiService>(classType: DocumentApiService),
    LazySingleton<GZipEncoder>(classType: GZipEncoder),
    LazySingleton<GZipDecoder>(classType: GZipDecoder),
    LazySingleton<DocumentService>(classType: DocumentService),
    LazySingleton<DocumentRepository>(classType: DocumentRepository),
    LazySingleton<EmbeddingRepository>(classType: EmbeddingRepository),
    LazySingleton<DocumentEmbeddingRepository>(
      classType: DocumentEmbeddingRepository,
    ),

    LazySingleton<RagConsoleApiService>(classType: RagConsoleApiService),

    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
