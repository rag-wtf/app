import 'package:logger/logger.dart';
import 'package:settings/src/app/app.locator.dart';

import 'setting_repository_test.dart' as setting_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  setting_repository.main(wasm: wasm);
}
