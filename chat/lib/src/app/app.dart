import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/conversation_message_repository.dart';
import 'package:chat/src/services/conversation_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:chat/src/ui/views/main/main_view.dart';
import 'package:chat/src/ui/views/startup/startup_view.dart';
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
    LazySingleton<ConversationRepository>(classType: ConversationRepository),
    LazySingleton<ConversationMessageRepository>(
      classType: ConversationMessageRepository,
    ),
    LazySingleton<MessageRepository>(classType: MessageRepository),
    LazySingleton<ChatService>(classType: ChatService),

    InitializableSingleton(
      classType: DatabaseService,
      asType: Surreal,
    ),
    LazySingleton(classType: ChatApiService),
// @stacked-service
  ],
  logger: StackedLogger(),
)
class App {}
