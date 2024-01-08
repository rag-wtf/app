import 'package:chat/src/app/app.locator.dart';

import 'conversation_repository_test.dart' as conversation_repository;

Future<void> main() async {
  await setupLocator();
  conversation_repository.main();
}
