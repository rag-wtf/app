import 'package:chat/src/app/app.locator.dart';

import 'chat_service_test.dart' as chat_service;
import 'conversation_message_repository_test.dart'
    as conversation_message_repository;
import 'conversation_repository_test.dart' as conversation_repository;
import 'message_repository_test.dart' as message_repository;

Future<void> main() async {
  await setupLocator();
  conversation_repository.main();
  message_repository.main();
  conversation_message_repository.main();
  chat_service.main();
}
