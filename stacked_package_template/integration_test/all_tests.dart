import 'package:logger/logger.dart';
import 'package:stacked_package_template/src/app/app.locator.dart';

import 'model_repository_test.dart' as model_repository;

Future<void> main() async {
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  await setupLocator();
  final wasm = const String.fromEnvironment('WASM').isNotEmpty;
  logger.i('WasmEngine: $wasm');
  model_repository.main(wasm: wasm);
}
