import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:document/src/ui/views/document_list/document_list_view.dart';
import 'package:document/src/ui/views/startup/startup_view.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: DocumentListView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<Dio>(classType: Dio),
    LazySingleton<DocumentApiService>(classType: DocumentApiService),
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<GZipEncoder>(classType: GZipEncoder),
    LazySingleton<GZipDecoder>(classType: GZipDecoder),
    LazySingleton<DocumentService>(classType: DocumentService),
    LazySingleton<DocumentRepository>(classType: DocumentRepository),
    LazySingleton<EmbeddingRepository>(classType: EmbeddingRepository),
    LazySingleton<DocumentEmbeddingRepository>(
      classType: DocumentEmbeddingRepository,
    ),
    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
    ),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
