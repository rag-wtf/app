import 'package:chat/src/app/app.locator.dart';
import 'package:logger/logger.dart';

import 'chat_message_repository_test.dart' as chat_message_repository;
import 'chat_repository_test.dart' as chat_repository;
import 'chat_service_test.dart' as chat_service;
import 'message_embedding_repository_test.dart' as message_embedding_repository;
import 'message_repository_test.dart' as message_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  chat_repository.main(wasm: wasm);
  message_repository.main(wasm: wasm);
  chat_message_repository.main(wasm: wasm);
  message_embedding_repository.main(wasm: wasm);
  chat_service.main(wasm: wasm);
}
