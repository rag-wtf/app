import 'package:chat/src/app/app.locator.dart';

import 'chat_message_repository_test.dart' as chat_message_repository;
import 'chat_repository_test.dart' as chat_repository;
import 'chat_service_test.dart' as chat_service;
import 'message_embedding_repository_test.dart' as message_embedding_repository;
import 'message_repository_test.dart' as message_repository;

Future<void> main() async {
  await setupLocator();
  chat_repository.main();
  message_repository.main();
  chat_message_repository.main();
  message_embedding_repository.main();
  chat_service.main();
}
