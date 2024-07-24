import 'package:database/src/app/app.locator.dart';
import 'package:logger/logger.dart';

import 'connection_setting_repository_test.dart'
    as connection_setting_repository;
import 'model_repository_test.dart' as model_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  connection_setting_repository.main();
  model_repository.main(wasm: wasm);
}
