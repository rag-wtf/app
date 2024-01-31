import 'package:archive/archive.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message_embedding_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:chat/src/ui/views/main/main_view.dart';
import 'package:chat/src/ui/views/startup/startup_view.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: MainView),
// @stacked-route
  ],
  dependencies: [
// document package
    LazySingleton<GZipEncoder>(classType: GZipEncoder),
    LazySingleton<GZipDecoder>(classType: GZipDecoder),
    LazySingleton<DocumentService>(classType: DocumentService),
    LazySingleton<DocumentRepository>(classType: DocumentRepository),
    LazySingleton<EmbeddingRepository>(classType: EmbeddingRepository),
    LazySingleton<DocumentEmbeddingRepository>(
      classType: DocumentEmbeddingRepository,
    ),
    LazySingleton<DocumentApiService>(classType: DocumentApiService),

    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<ChatRepository>(classType: ChatRepository),
    LazySingleton<ChatMessageRepository>(
      classType: ChatMessageRepository,
    ),
    LazySingleton<MessageRepository>(classType: MessageRepository),
    LazySingleton<MessageEmbeddingRepository>(
      classType: MessageEmbeddingRepository,
    ),
    LazySingleton<ChatService>(classType: ChatService),

    LazySingleton<Dio>(classType: Dio),
    LazySingleton<ChatApiService>(classType: ChatApiService),

    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
    ),

// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
