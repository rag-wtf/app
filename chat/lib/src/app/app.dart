import 'package:archive/archive.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message_embedding_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:chat/src/services/stream_response_service/http_stream_response_service.dart';
import 'package:chat/src/services/stream_response_service/stream_response_service.dart';
import 'package:chat/src/ui/views/main/main_view.dart';
import 'package:chat/src/ui/views/startup/startup_view.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:settings/settings.dart';
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
    LazySingleton<FlutterSecureStorage>(classType: FlutterSecureStorage),
    LazySingleton<ConnectionSettingRepository>(
      classType: ConnectionSettingRepository,
    ),
    LazySingleton<ConnectionSettingService>(
      classType: ConnectionSettingService,
    ),
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
    LazySingleton<BatchService>(classType: BatchService),

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
    LazySingleton<StreamResponseService>(
      classType: HttpStreamResponseService,
      asType: StreamResponseService,
    ),
    LazySingleton<Surreal>(
      classType: SurrealWasm,
      asType: Surreal,
      resolveUsing: SurrealWasm.getInstance,
    ),

// @stacked-service
  ],
  dialogs: [
    StackedDialog(classType: ConnectionDialog),
    StackedDialog(classType: EmbeddingDialog),
    StackedDialog(classType: InfoAlertDialog),
// @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
