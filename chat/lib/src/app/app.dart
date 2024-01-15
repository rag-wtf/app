import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:chat/src/ui/views/main/main_view.dart';
import 'package:chat/src/ui/views/startup/startup_view.dart';
import 'package:dio/dio.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:chat/src/services/chat_api_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: MainView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton<NavigationService>(classType: NavigationService),
    LazySingleton<SettingService>(classType: SettingService),
    LazySingleton<SettingRepository>(classType: SettingRepository),
    LazySingleton<ChatRepository>(classType: ChatRepository),
    LazySingleton<ChatMessageRepository>(
      classType: ChatMessageRepository,
    ),
    LazySingleton<MessageRepository>(classType: MessageRepository),
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
