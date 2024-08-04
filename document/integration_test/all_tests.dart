import 'package:document/src/app/app.locator.dart';
import 'package:logger/logger.dart';

import 'document_embedding_repository_test.dart'
    as document_embedding_repository;
import 'document_repository_test.dart' as document_repository;
import 'document_service_test.dart' as document_service;
import 'embedding_repository_test.dart' as embedding_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  //document_repository.main(wasm: wasm);
  embedding_repository.main(wasm: wasm);
  //document_embedding_repository.main(wasm: wasm);
  //document_service.main(wasm: wasm);
}
